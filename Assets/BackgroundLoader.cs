using UnityEngine;
using UnityEngine.UI;
//using UnityEngine.UIElements;

public class BackgroundLoader : MonoBehaviour
{
    // Reference to the UI dropdown for selecting folders
    public Dropdown folderDropdown;

    public Paralax paralax;

    // Array to hold loaded background images
    private Sprite[] backgroundImages;

    // Reference to the Image component to display the selected background image
    public Image backgroundImage;

    public bool isBlur = false;


    void Start()
    {
        // Load folder names into the dropdown
        //LoadFolders();
    }

    // Load folder names from the "Resources" folder into the dropdown
    void LoadFolders()
    {
        // Clear existing options in the dropdown
        folderDropdown.ClearOptions();

        // Get all folder names from the "Resources" folder
        string[] folders = System.IO.Directory.GetDirectories(Application.dataPath + "/Resources/Backgrounds/"); // + isBlur ? "blur" : "no blur"

        // Extract folder names and add them to the dropdown options
        foreach (string folderPath in folders)
        {
            string folderName = System.IO.Path.GetFileName(folderPath);
            folderDropdown.options.Add(new Dropdown.OptionData(folderName));
        }

        // Update the dropdown
        folderDropdown.RefreshShownValue();
    }

    // Load background images from the selected folder
    public void LoadBackgroundImages(Sprite[] layers)
    {
        // Get the selected folder from the dropdown
        //string folderName = folderDropdown.options[folderDropdown.value].text;

        // Load background images from the selected folder
        //backgroundImages = Resources.LoadAll<Sprite>("Backgrounds/" + folderName + (isBlur ? "/blur" : "/no blur"));
        //backgroundImages = Resources.LoadAll<Sprite>("Backgrounds/" + chapterName + "/" + levelName);


        //        Debug.Log(folderName + (isBlur ? "/blur" : "/no blur"));
        //Debug.Log("Image Count: " + backgroundImages.Length);
        //Debug.Log("Image Count: " + layers.Length);

        // Display the first 5 background images
        for (int i = 0; i < layers.Length; i++)
        {
                paralax.backgrounds[i].GetComponent<SpriteRenderer>().sprite = layers[(layers.Length - 1) -i];
                paralax.backgroundClones[i].GetComponent<SpriteRenderer>().sprite = layers[(layers.Length - 1) - i];
                //Debug.Log("Image #: " + i);

        }

        // Display the first background image
        /* if (backgroundImages.Length > 0)
         {
             //backgroundImage.sprite = backgroundImages[0];
         }
         else
         {
             Debug.LogWarning("No background images found in folder: " + folderName);
         }*/
    }
}