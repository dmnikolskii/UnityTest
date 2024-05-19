using System.Collections;
using UnityEngine;

public class SettingsState : GameState
{
    private readonly GameStateMachine gameStateMachine;
    private readonly Animator animator;
    public SettingsState(GameStateMachine gameStateMachine) : base(gameStateMachine)
    {
        this.gameStateMachine = gameStateMachine;
        animator = GameObject.Find("Settings Panel").GetComponent<Animator>();

        // Get all components attached to the GameObject
    }

    public override void OnStateEnter()
    {
        gameStateMachine.StartCoroutine(WaitAndAppear());
        //LevelMenuManager.Instance.UpdateLevelButtons(); 
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