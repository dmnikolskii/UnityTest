using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/*public enum GameState
{
    Initialize,
    MainMenu,
    LevelSelect,
    Level
}*/

public abstract class GameState
{
    protected readonly GameStateMachine gamesstate;

    public GameState (GameStateMachine gamesstate)
    {
        this.gamesstate = gamesstate;
    }

    public virtual void Update() { }
    public virtual void OnStateEnter() { }
    public virtual void OnStateExit() { }
}