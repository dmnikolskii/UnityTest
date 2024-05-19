using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class GameStateMachine : MonoBehaviour
{
    private Dictionary<Type, GameState> _states = new Dictionary<Type, GameState>();
    private GameState currentState { get; set; }

    void Awake() 
    { 
        DontDestroyOnLoad(this); 
    }

    private void Start()
    {
        /*states = new Dictionary<GameState, IGameState>
        {
            { GameState.Initialize, new InitializeState(this) },
            { GameState.MainMenu, new MainMenuState(this) },
            { GameState.LevelSelect, new LevelSelectState(this) },
            { GameState.Level, new LevelState(this) }
        };*/

        AddState(new InitializeState(this));
        AddState(new MainMenuState(this));
        AddState(new SettingsState(this));
        AddState(new LevelSelectState(this));
        AddState(new LevelState(this));
        AddState(new QuitState(this));

        SetState<InitializeState>();
    }

    public void AddState(GameState state)
    {
        _states.Add(state.GetType(), state);
    }

    public void SetState<T>() where T : GameState
    {
        var type = typeof(T);

        Debug.Log("======================");
        Debug.Log("Previous state: " + currentState?.GetType());
        Debug.Log("Switching to: " + type);
 

        if (currentState?.GetType() == type)
        {
            return;
        }

        if (_states.TryGetValue(type, out var newstate))
        {
            currentState?.OnStateExit();
            currentState = newstate;
            currentState.OnStateEnter();
        }
    }

    private void Update()
    {
        currentState?.Update();
    }
}