using UnityEngine;

[CreateAssetMenu(fileName = "LevelsContainer", menuName = "Game/Levels Container", order = 2)]
public class LevelsContainer : ScriptableObject
{
    public LevelData[] levels;
}