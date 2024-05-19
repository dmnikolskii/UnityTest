using UnityEngine;

public class LinesDrawer : MonoBehaviour
{

    public GameObject linePrefab;
    public LayerMask cantDrawOverLayer;
    int cantDrawOverLayerIndex;

    [Space(30f)]
    public Gradient lineColor;
    public float linePointsMinDistance;
    public float lineWidth;

    LineAdv currentLine;

    Camera cam;


    void Start()
    {
        cam = Camera.main;
        cantDrawOverLayerIndex = LayerMask.NameToLayer("CantDrawOver");
    }

    void LateUpdate()
    {
        if (Input.GetMouseButtonDown(0))
            BeginDraw();

        if (currentLine != null)
            Draw();

        if (Input.GetMouseButtonUp(0))
            EndDraw();
    }

    // Begin Draw ----------------------------------------------
    void BeginDraw()
    {
        currentLine = Instantiate(linePrefab, this.transform).GetComponent<LineAdv>();

        //Set line properties
        currentLine.UsePhysics(false);
        currentLine.SetLineColor(lineColor);
        currentLine.SetPointsMinDistance(linePointsMinDistance);
        currentLine.SetLineWidth(lineWidth);

    }
    // Draw ----------------------------------------------------
    void Draw()
    {
        Vector2 mousePosition = cam.ScreenToWorldPoint(Input.mousePosition);

        //Check if mousePos hits any collider with layer "CantDrawOver", if true cut the line by calling EndDraw( )
        RaycastHit2D hit = Physics2D.CircleCast(mousePosition, lineWidth , Vector2.zero, 1f, cantDrawOverLayer);
        Collider2D[] overlappingColliders = Physics2D.OverlapCircleAll(mousePosition, lineWidth, cantDrawOverLayer);

        if (hit || overlappingColliders.Length > 0)
        {
            Debug.Log("HITTTTT");
            EndDraw();

        }
        else
            currentLine.AddPoint(mousePosition);
    }
    // End Draw ------------------------------------------------
    void EndDraw()
    {
        if (currentLine != null)
        {
            if (currentLine.pointsCount < 2)
            {
                //If line has one point
                Destroy(currentLine.gameObject);
            }
            else
            {
                //Add the line to "CantDrawOver" layer
                currentLine.gameObject.layer = cantDrawOverLayerIndex;
                //currentLine.gameObject.tag = "line";

                //Activate Physics on the line
                currentLine.UsePhysics(true);

                currentLine = null;
            }
        }
    }
}