using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LevelSelectOnEnable : MonoBehaviour
{
    private void OnAppear()
    {
        LevelMenuManager.Instance.UpdateLevelButtons();
        Debug.Log("Level Selection Window OnEnable");
    }
}
