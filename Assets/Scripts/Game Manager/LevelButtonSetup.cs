using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class LevelButtonSetup : MonoBehaviour
{
    public Button levelButton;
    public Text textElement;
    //public string levelID;  // Для отображения спрайта уровня
    public GameObject lockIcon;  // Иконка замка для заблокированных уровней

    private LevelData levelData;  // Данные текущего уровня

    [SerializeField] private BackgroundLoader bgLoader;

    public void SetupButton(LevelData data)
    {
        levelData = data;

        bgLoader = GameObject.Find("Paralax Canvas").GetComponent<BackgroundLoader>(); 

        //    public string levelName;
        //public string soundCaption;
        //public string chapterName;

        levelButton.onClick.AddListener(() => LoadLevel(levelData));
        //levelImage.sprite = levelData.levelSprite;

        // Проверяем, разблокирован ли уровень
        if (!levelData.isUnlocked)
        {
            lockIcon.SetActive(true);
            levelButton.interactable = false;
        }
        else
        {
            lockIcon.SetActive(false);
            levelButton.interactable = true;
        }
        textElement.text = levelData.levelID.ToString();
    }

    private void LoadLevel(LevelData levelData)
    {
        AudioManager.instance.PlaySFX(levelData.soundCaption); // Play click sound

        if (levelData.isUnlocked)
        {
            Debug.Log("Loading level: " + levelData.levelName);  // Замените на загрузку сцены
            // SceneManager.LoadScene(levelData.levelName);
            bgLoader.LoadBackgroundImages(levelData.paralax_layer);
            LevelMenuManager.Instance.UnlockLevel(levelData.levelID + 1); // Тестово разлочим следующий уровень
        }
        else
        {
            Debug.Log("This level is locked.");
        }
    }
}