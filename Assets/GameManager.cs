using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    public GameStateMachine StateMachine;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    public void Play()
    {
        StateMachine.SetState<LevelSelectState>();
    }

    public void Settings()
    {
        StateMachine.SetState<SettingsState>();
    }

    public void BackToMainMenu()
    {
        StateMachine.SetState<MainMenuState>();
    }

    public void Quit()
    {
        StateMachine.SetState<QuitState>();
    }


}
