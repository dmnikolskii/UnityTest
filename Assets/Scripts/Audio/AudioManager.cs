using System;
using UnityEngine;
using UnityEngine.UI;

public class AudioManager : MonoBehaviour
{
    public static AudioManager instance;
    [SerializeField] public SoundSample[] musicSounds, sfxSounds;
    [SerializeField] private AudioSource musicSource, sfxSource;

    public Slider musicVolumeSlider;
    public Slider sfxVolumeSlider;

    public Toggle vibrationToggle;

    private const string MusicVolumeKey = "MusicVolume";
    private const string SfxVolumeKey = "SfxVolume";

    private const string VibrationKey = "VibrationToggle";

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
        } 
        else
        {
            Destroy(gameObject);
        }
    }

    private void Start()
    {
        PlayMusic("MenuBackground");

        float savedVolume;
        bool vibration;

        // Initialize slider with current volume level
        if (musicVolumeSlider != null)
        {
            // Initialize slider with saved volume level or default value
            savedVolume = PlayerPrefs.GetFloat(MusicVolumeKey, 0.9f);
            musicVolumeSlider.value = savedVolume;
            musicSource.volume = savedVolume;
        }

        if (sfxVolumeSlider != null)
        {
            savedVolume = PlayerPrefs.GetFloat(SfxVolumeKey, 0.9f);
            sfxVolumeSlider.value = savedVolume;
            sfxSource.volume = savedVolume;
        }

        if (vibrationToggle != null)
        {
            vibration = PlayerPrefs.GetInt(VibrationKey, 1) == 1;
            vibrationToggle.isOn = vibration;            
        }

    }

    public void PlayMusic(string name)
    {
        if (name == "") return;

        SoundSample s = Array.Find(musicSounds, s => s.name == name);
       
        if (s == null)
        {
            Debug.Log($"Music sample {name} not found");
            return;
        }        

        musicSource.clip = s.clip;
        musicSource.Play();
        Debug.Log($"Music sample {name} played");
        
    }

    public void PlaySFX(string name)
    {
        if (name == "") return;

        SoundSample s = Array.Find(sfxSounds, s => s.name == name);
        if (s == null)
        {
            Debug.Log($"SFX sample {name} not found");
            return;
        }

        sfxSource.clip = s.clip;
        sfxSource.Play();
        Debug.Log($"SFX sample {name} played");
        
    }

    public void Vibrate()
    {
        if (SystemInfo.supportsVibration)
        {
            Handheld.Vibrate();
        }
        else
        {
            Debug.LogWarning("Device does not support vibration.");
        }

        // Additional button press logic here...
    }

    // Called when the volume slider value changes
    public void OnMusicVolumeChanged(float volume)
    {
        // Update music source volume
        musicSource.volume = volume;
        PlayerPrefs.SetFloat(MusicVolumeKey, volume);
        PlayerPrefs.Save();
    }

    public void OnSfxVolumeChanged(float volume)
    {
        // Update music source volume
        sfxSource.volume = volume;
        PlayerPrefs.SetFloat(SfxVolumeKey, volume);
        PlayerPrefs.Save();
    }

    public void OnVibrationChanged(bool isOn)
    {
        // Update music source volume
        vibrationToggle.isOn = isOn;
        PlayerPrefs.SetInt(VibrationKey, isOn ? 1:0);
        PlayerPrefs.Save();
    }


}
