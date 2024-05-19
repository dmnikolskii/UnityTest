using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LevelMenuManager : MonoBehaviour
{
    public Transform buttonsParent;  // Родительский объект для кнопок
    public GameObject buttonPrefab;  // Префаб кнопки уровня
    public LevelsContainer levelsContainer;  // Ссылка на контейнер уровней

    public static LevelMenuManager Instance { get; private set; }

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

    private void Start()
    {
        LoadLevels();
        //UpdateLevelButtons();
    }

    public void UpdateLevelButtons()
    {
        foreach (Transform child in buttonsParent.transform)
        {
            Destroy(child.gameObject);
        }

        foreach (LevelData level in levelsContainer.levels)
        {
            GameObject buttonObj = Instantiate(buttonPrefab, buttonsParent);
            LevelButtonSetup buttonSetup = buttonObj.GetComponent<LevelButtonSetup>();
            buttonSetup.SetupButton(level);
        }
    }

    public void UnlockLevel(int levelID)
    {
        foreach (var level in levelsContainer.levels)
        {
            if (level.levelID == levelID)
            {
                level.isUnlocked = true;
                Debug.Log($"Unlocking {levelID} level");
                SaveLevels();
                break;
            }
        }
        UpdateLevelButtons();
    }

    private bool CheckIfPlayerPrefExists()
    {
        return PlayerPrefs.GetInt("PrefsExists", 0) == 1;
    }

    private void InitializePrefs()
    {
        PlayerPrefs.SetInt("PrefsExists", 1);
        PlayerPrefs.SetInt("Level_1", 1);
        PlayerPrefs.Save();
    }

    private void SaveLevels()
    {
        for (int i = 0; i < levelsContainer.levels.Length; i++)
        {
            PlayerPrefs.SetInt("Level_" + levelsContainer.levels[i].levelID, levelsContainer.levels[i].isUnlocked ? 1 : 0);
        }
        PlayerPrefs.Save();
        Debug.Log("Game progress has been saved");
    }

    private void LoadLevels()
    {
        //ResetAllPreferences();
        if (!CheckIfPlayerPrefExists()) InitializePrefs();
        //if (!CheckIfPlayerPrefExists("Level_0")) return;

        for (int i = 0; i < levelsContainer.levels.Length; i++)
        {
            int levelStatus = PlayerPrefs.GetInt("Level_" + levelsContainer.levels[i].levelID, 0);
            levelsContainer.levels[i].isUnlocked = levelStatus == 1;
        }
        Debug.Log("Game progress has been loaded");
        UpdateLevelButtons();
    }

    public void ResetAllPreferences()
    {
        PlayerPrefs.DeleteAll();
        PlayerPrefs.Save();  // Ensure that the reset is immediately saved to disk
        Debug.Log("All PlayerPrefs have been reset.");

        LoadLevels();

    }

}
