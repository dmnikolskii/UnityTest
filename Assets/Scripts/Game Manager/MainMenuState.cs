using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MainMenuState : GameState
{
    private readonly GameStateMachine gameStateMachine;
    private Animator animator;

    public MainMenuState(GameStateMachine gameStateMachine) : base(gameStateMachine)
    {
        this.gameStateMachine = gameStateMachine;
        animator = GameObject.Find("Main Panel").GetComponent<Animator>();

    }

    public override void OnStateEnter()
    {
        gameStateMachine.StartCoroutine(WaitAndAppear());
        // Load main menu UI
        // Attach event listeners for UI elements
        // For example, a button in your UI could call:
        // gameStateMachine.TransitionToState(GameState.LevelSelect);
        Debug.Log("Главное меню");

    }

    public override void OnStateExit()
    {
        gameStateMachine.StartCoroutine(WaitAndDisappear());
        // Hide main menu UI or perform cleanup
    }

    IEnumerator WaitAndAppear()
    {
        // Wait for 1 second

        yield return new WaitForSeconds(0.7f);

        if (animator != null)
        {
            // Trigger the "Disappear" animation
            animator.SetTrigger("Appear");
        }
        //yield return new WaitForSeconds(1f);

        //GameObject.Find("Level Select").SetActive(false);
        // Hide level selection UI
    }

    IEnumerator WaitAndDisappear()
    {
        // Wait for 1 second

        if (animator != null)
        {
            // Trigger the "Disappear" animation
            animator.SetTrigger("Disappear");
        }
        yield return new WaitForSeconds(0f);

        //GameObject.Find("Level Select").SetActive(false);
        // Hide level selection UI
    }


}