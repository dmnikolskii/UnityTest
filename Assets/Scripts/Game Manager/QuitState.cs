using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class QuitState : GameState
{
    private readonly GameStateMachine gameStateMachine;

    public QuitState(GameStateMachine gameStateMachine) : base(gameStateMachine)
    {
        this.gameStateMachine = gameStateMachine;
    }

    public override void OnStateEnter()
    {
        // Initialization logic here
        // After initialization, transition to the main menu
        Debug.Log("Quitting...");
        Application.Quit();
    }

    public override void OnStateExit()
    {
        // Cleanup if needed
        Debug.Log("Выход из Quitting");

    }
}