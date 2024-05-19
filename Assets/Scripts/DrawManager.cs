using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawManager : MonoBehaviour
{
    private Camera _cam;
    [SerializeField] private Line _linePrefab;

    public const float RESOLUTION = .1f;

    private Line _currentLine;
    void Start()
    {
        _cam = Camera.main;
    }


    void Update()
    {
        Vector2 mousePos = _cam.ScreenToWorldPoint(Input.mousePosition);
        Debug.Log(mousePos);

        if (Input.GetMouseButtonDown(0)) { 

            _currentLine = Instantiate(_linePrefab, mousePos, Quaternion.identity);
        _currentLine.transform.position = mousePos;
    }

        //_currentLine.transform.position = mousePos;
        if (Input.GetMouseButton(0)) _currentLine.SetPosition(mousePos);
    }
}