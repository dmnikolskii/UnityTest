using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OptionsState : GameState
{
    private readonly GameStateMachine gameStateMachine;

    public OptionsState(GameStateMachine gameStateMachine) : base(gameStateMachine)
    {
        this.gameStateMachine = gameStateMachine;
    }

    public override void OnStateEnter()
    {
        // Load and initialize the level
    }

    public override void OnStateExit()
    {
        // Clean up the level (e.g., unload assets)
    }
}