using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InitializeState : GameState
{
    private readonly GameStateMachine gameStateMachine;

    public InitializeState(GameStateMachine gameStateMachine) : base(gameStateMachine)
    {
        this.gameStateMachine = gameStateMachine;
    }

    public override void OnStateEnter()
    {
        // Initialization logic here
        // After initialization, transition to the main menu
        Debug.Log("Инициализация");
        gameStateMachine.SetState<MainMenuState>();
    }

    public override void OnStateExit()
    {
        // Cleanup if needed
        Debug.Log("Выход из инициализации");

    }
}