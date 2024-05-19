using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class LevelSelectState : GameState
{
    private readonly GameStateMachine gameStateMachine;
    private Animator animator;
    public LevelSelectState(GameStateMachine gameStateMachine) : base(gameStateMachine)
    {
        this.gameStateMachine = gameStateMachine;
        animator = GameObject.Find("Level Select Panel").GetComponent<Animator>();
    }

    public override void OnStateEnter()
    {
        gameStateMachine.StartCoroutine(WaitAndAppear());

        //LevelMenuManager.Instance.UpdateLevelButtons(); 
    }

    public void LoadLevel(string levelId)
    {
        // Set up data for the level to be loaded
        gameStateMachine.SetState<LevelState>();
    }

    public override void OnStateExit()
    {
        gameStateMachine.StartCoroutine(WaitAndDisappear());
       
    }
    IEnumerator WaitAndAppear()
    {
        yield return new WaitForSeconds(0.7f);

        if (animator != null)
        {
            animator.SetTrigger("Appear");
        }
    }

    IEnumerator WaitAndDisappear()
    {
        if (animator != null)
        {
            animator.SetTrigger("Disappear");
        }
        yield return new WaitForSeconds(0f);
    }

}