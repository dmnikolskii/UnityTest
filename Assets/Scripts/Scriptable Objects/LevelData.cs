using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "Custom Assets/Level Button", fileName = "Level Button", order = 1)]
public class LevelData : ScriptableObject
{
    public bool isUnlocked = true;
    public int levelID = 1;
    public string levelName;
    public string soundCaption;
    public string chapterName;

    [Header("Paralax Backgrounds")]
    [SerializeField] public Sprite[] paralax_layer;
}
