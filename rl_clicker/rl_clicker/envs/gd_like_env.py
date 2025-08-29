import gymnasium as gym
import numpy as np
from gymnasium import spaces


class GDLiteRunnerEnv(gym.Env):
	"""
	A simple 2D runner environment with one action: click to jump.
	- Observation: 84x84 grayscale image (uint8)
	- Action: Discrete(2) -> 0: do nothing, 1: click (jump)
	- Reward: +1 per step alive, -1 on collision, +100 on reaching end
	- Episode ends on collision or when level_length is reached
	
	Rendering is offscreen via NumPy array operations.
	"""

	metadata = {"render_modes": ["rgb_array"], "render_fps": 60}

	def __init__(self,
				frame_size: int = 84,
				level_length: int = 2000,
				obstacle_gap: int = 120,
				max_obstacles: int = 5,
				gravity: float = 0.6,
				jump_velocity: float = -9.5,
				player_x: int = 15,
				player_size: int = 8,
				obstacle_width: int = 6,
				obstacle_min_height: int = 12,
				obstacle_max_height: int = 42,
				bg_color: int = 0,
				fg_color: int = 255):
		super().__init__()
		self.frame_size = frame_size
		self.level_length = level_length
		self.obstacle_gap = obstacle_gap
		self.max_obstacles = max_obstacles
		self.gravity = gravity
		self.jump_velocity = jump_velocity
		self.player_x = player_x
		self.player_size = player_size
		self.obstacle_width = obstacle_width
		self.obstacle_min_height = obstacle_min_height
		self.obstacle_max_height = obstacle_max_height
		self.bg_color = bg_color
		self.fg_color = fg_color

		self.observation_space = spaces.Box(low=0, high=255, shape=(frame_size, frame_size), dtype=np.uint8)
		self.action_space = spaces.Discrete(2)

		self._rng = np.random.default_rng()
		self._reset_state()

	def _reset_state(self):
		self.timestep = 0
		self.player_y = self.frame_size - (self.player_size + 2)
		self.player_vel = 0.0
		self.obstacles = []  # list of dicts with x and height
		self.next_obstacle_x = self.frame_size + 20
		self.done = False
		self.total_reward = 0.0

	def reset(self, *, seed: int | None = None, options: dict | None = None):
		if seed is not None:
			self._rng = np.random.default_rng(seed)
		self._reset_state()
		obs = self._render_frame()
		info = {}
		return obs, info

	def step(self, action: int):
		if self.done:
			raise RuntimeError("step() called after episode done. Call reset().")

		# Action: jump if grounded
		if action == 1 and self._is_grounded():
			self.player_vel = self.jump_velocity

		# Physics update
		self.player_vel += self.gravity
		self.player_y = min(self.player_y + self.player_vel, self.frame_size - (self.player_size + 2))
		if self.player_y < 0:
			self.player_y = 0

		# Spawn/move obstacles
		self._maybe_spawn_obstacle()
		self._move_obstacles()

		# Collision check
		terminated = self._check_collision()
		truncated = self.timestep >= self.level_length
		self.timestep += 1

		reward = 1.0
		if terminated:
			reward = -1.0
		elif truncated:
			reward = 100.0

		self.total_reward += reward
		self.done = terminated or truncated
		obs = self._render_frame()
		info = {"timestep": self.timestep, "total_reward": self.total_reward}
		return obs, reward, terminated, truncated, info

	def _is_grounded(self) -> bool:
		return self.player_y >= self.frame_size - (self.player_size + 2) - 1

	def _maybe_spawn_obstacle(self):
		if len(self.obstacles) == 0:
			self.next_obstacle_x = self.frame_size + self._rng.integers(10, 30)
		elif self.obstacles[-1]["x"] < self.frame_size - self.obstacle_gap and len(self.obstacles) < self.max_obstacles:
			self.next_obstacle_x = max(self.next_obstacle_x, self.frame_size + self._rng.integers(20, 50))

		# Spawn when time
		if (len(self.obstacles) == 0 and self.next_obstacle_x <= self.frame_size + 2) or \
		   (len(self.obstacles) > 0 and self.obstacles[-1]["x"] <= self.frame_size - self.obstacle_gap):
			height = int(self._rng.integers(self.obstacle_min_height, self.obstacle_max_height))
			self.obstacles.append({"x": self.frame_size + 2, "h": height})

	def _move_obstacles(self):
		for obs in self.obstacles:
			obs["x"] -= 2
		# Remove off-screen
		self.obstacles = [o for o in self.obstacles if o["x"] + self.obstacle_width > 0]

	def _check_collision(self) -> bool:
		px1 = self.player_x
		px2 = self.player_x + self.player_size
		py1 = int(self.player_y)
		py2 = int(self.player_y + self.player_size)
		for obs in self.obstacles:
			ox1 = obs["x"]
			ox2 = obs["x"] + self.obstacle_width
			oy1 = self.frame_size - obs["h"]
			oy2 = self.frame_size
			# AABB overlap
			if px1 < ox2 and px2 > ox1 and py1 < oy2 and py2 > oy1:
				return True
		return False

	def _render_frame(self) -> np.ndarray:
		frame = np.full((self.frame_size, self.frame_size), self.bg_color, dtype=np.uint8)
		# Draw ground line
		frame[self.frame_size - 1, :] = self.fg_color
		# Draw player
		py1 = max(0, int(self.player_y))
		py2 = min(self.frame_size, int(self.player_y + self.player_size))
		px1 = max(0, int(self.player_x))
		px2 = min(self.frame_size, int(self.player_x + self.player_size))
		if py2 > py1 and px2 > px1:
			frame[py1:py2, px1:px2] = self.fg_color
		# Draw obstacles
		for obs in self.obstacles:
			ox1 = max(0, int(obs["x"]))
			ox2 = min(self.frame_size, int(obs["x"] + self.obstacle_width))
			oy1 = max(0, int(self.frame_size - obs["h"]))
			oy2 = self.frame_size
			if oy2 > oy1 and ox2 > ox1:
				frame[oy1:oy2, ox1:ox2] = self.fg_color
		return frame

	def render(self):
		return np.repeat(self._render_frame()[..., None], 3, axis=-1)


class FrameStackWrapper(gym.Wrapper):
	"""Stack last K grayscale frames along channel dimension."""
	def __init__(self, env: gym.Env, num_stack: int = 4):
		super().__init__(env)
		self.num_stack = num_stack
		shape = (env.observation_space.shape[0], env.observation_space.shape[1], num_stack)
		self.observation_space = spaces.Box(low=0, high=255, shape=shape, dtype=np.uint8)
		self._frames = None

	def reset(self, **kwargs):
		obs, info = self.env.reset(**kwargs)
		self._frames = [obs for _ in range(self.num_stack)]
		return self._get_obs(), info

	def step(self, action):
		obs, reward, terminated, truncated, info = self.env.step(action)
		self._frames.pop(0)
		self._frames.append(obs)
		return self._get_obs(), reward, terminated, truncated, info

	def _get_obs(self):
		return np.stack(self._frames, axis=-1)