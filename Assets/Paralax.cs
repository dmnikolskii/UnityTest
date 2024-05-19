using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Paralax : MonoBehaviour
{
    // Speed multiplier for each GameObject.
    public float[] parallaxEffectMultipliers;

    // The initial positions of the GameObjects.
    private Vector3[] initialPositions;

    // Width of the backgrounds for looping.
    public float[] backgroundWidths;

    // Speed at which the background moves.
    public float backgroundSpeed = 1f;
    // References to the background GameObjects
    public GameObject[] backgrounds;
    // Cloned GameObjects for seamless looping
    public GameObject[] backgroundClones;

    // Order in layer for each background
    public int[] ordersInLayer;

    void Start()
    {
        // Initialize the initialPositions array based on the number of backgrounds.
        initialPositions = new Vector3[backgrounds.Length];
        backgroundClones = new GameObject[backgrounds.Length];

        // Record the initial position of each background GameObject and create clones.
        for (int i = 0; i < backgrounds.Length; i++)
        {
            if (backgrounds[i] != null)
            {
                initialPositions[i] = backgrounds[i].transform.position;
                // Clone and position right next to the original
                backgroundClones[i] = Instantiate(backgrounds[i], new Vector3(initialPositions[i].x + backgroundWidths[i], initialPositions[i].y, initialPositions[i].z), Quaternion.identity);
                backgroundClones[i].transform.SetParent(backgrounds[i].transform.parent, true);
                backgroundClones[i].transform.localScale = backgrounds[i].transform.localScale;

                SetOrderInLayer(backgrounds[i], ordersInLayer[i]);
                SetOrderInLayer(backgroundClones[i], ordersInLayer[i]);

            }
        }
    }

    void Update()
    {
        for (int i = 0; i < backgrounds.Length; i++)
        {
            if (backgrounds[i] != null)
            {
                // Calculate the parallax movement.
                float parallax = parallaxEffectMultipliers[i] * backgroundSpeed * Time.deltaTime;
                backgrounds[i].transform.Translate(-parallax, 0, 0);
                backgroundClones[i].transform.Translate(-parallax, 0, 0);

                // Check if the original or cloned background needs to be reset.
                if (backgrounds[i].transform.position.x <= initialPositions[i].x - backgroundWidths[i])
                {
                    backgrounds[i].transform.position = new Vector3(initialPositions[i].x, initialPositions[i].y, initialPositions[i].z);
                    backgroundClones[i].transform.position = new Vector3(initialPositions[i].x + backgroundWidths[i], initialPositions[i].y, initialPositions[i].z);
                }
            }
        }
    }

    // Helper method to set the order in layer
    private void SetOrderInLayer(GameObject obj, int order)
    {
        if (obj.GetComponent<Renderer>() != null)
        {
            obj.GetComponent<Renderer>().sortingOrder = order;
        }
    }

}
