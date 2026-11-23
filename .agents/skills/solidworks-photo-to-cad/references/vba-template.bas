' =============================================================================
' SOLIDWORKS 2026 VBA MACRO TEMPLATE — HUMAN-LIKE PARAMETRIC MODELING
' Base scaffold for Photo-to-CAD reconstruction. Replace the example modeling
' block in BuildPartFeatures() with the target part's sketches & features.
' =============================================================================
Option Explicit

Private Const PI As Double = 3.14159265358979
Private Const TASK_NAME As String = "Part_01"
Private Const VERSION_TAG As String = "v001"

Sub main()
    Dim swApp As SldWorks.SldWorks
    Dim swModel As SldWorks.ModelDoc2
    Dim swPart As SldWorks.PartDoc
    Dim swFeatMgr As SldWorks.FeatureManager
    Dim swSketchMgr As SldWorks.SketchManager
    Dim prevInputDimVal As Boolean
    Dim toggledPref As Boolean
    Dim outDir As String
    Dim sldprtPath As String
    Dim stepPath As String
    Dim errStep As String

    On Error GoTo ErrHandler

    errStep = "Attach to SOLIDWORKS"
    Set swApp = Application.SldWorks
    If swApp Is Nothing Then
        Err.Raise vbObjectError + 1001, "main", "Unable to access SOLIDWORKS Application."
    End If

    ' Suppress interactive dimension input popup during API Smart Dimensioning
    prevInputDimVal = swApp.GetUserPreferenceToggle(swUserPreferenceToggle_e.swInputDimValOnCreate)
    swApp.SetUserPreferenceToggle swUserPreferenceToggle_e.swInputDimValOnCreate, False
    toggledPref = True

    errStep = "Create Part Document"
    Set swModel = CreatePartDocSafe(swApp)
    If swModel Is Nothing Then
        Err.Raise vbObjectError + 1002, "main", "Failed to create a new SOLIDWORKS Part document."
    End If

    Set swPart = swModel
    Set swFeatMgr = swModel.FeatureManager
    Set swSketchMgr = swModel.SketchManager

    ' Ensure MMGS display units (API calls always use meters/radians)
    swModel.SetUserPreferenceIntegerValue swUserPreferenceIntegerValue_e.swUnitSystem, swUnitSystem_e.swUnitSystem_MMGS

    errStep = "Build Parametric Sketches and Features"
    BuildPartFeatures swModel, swFeatMgr, swSketchMgr, errStep

    ' Apply instructor-matching steel tone & Shaded With Edges (Tier 3 visual default)
    ApplyDefaultAppearance swApp, swModel, swPart

    errStep = "Rebuild Model"
    If Not swModel.ForceRebuild3(False) Then
        Err.Raise vbObjectError + 1003, "main", "ForceRebuild3 reported rebuild failure."
    End If

    errStep = "Verify Geometry"
    VerifyPartGeometry swModel, swPart

    swModel.ShowNamedView2 "*Isometric", 7
    swModel.ViewZoomtofit2

    errStep = "Prepare Versioned Output Folder"
    outDir = CurDir$() & "\outputs\" & TASK_NAME & "\" & VERSION_TAG
    EnsureFolderChain CurDir$() & "\outputs", TASK_NAME, VERSION_TAG
    sldprtPath = outDir & "\" & TASK_NAME & "_" & VERSION_TAG & ".SLDPRT"
    stepPath = outDir & "\" & TASK_NAME & "_" & VERSION_TAG & ".STEP"

    errStep = "Save Native SLDPRT"
    SavePartSafe swModel, sldprtPath

    errStep = "Export Neutral STEP"
    SavePartSafe swModel, stepPath

Cleanup:
    If Not swApp Is Nothing And toggledPref Then
        swApp.SetUserPreferenceToggle swUserPreferenceToggle_e.swInputDimValOnCreate, prevInputDimVal
    End If
    Exit Sub

ErrHandler:
    MsgBox "SOLIDWORKS macro failed at step: " & errStep & vbCrLf & _
           "Error " & Err.Number & ": " & Err.Description, vbCritical, "CAD Automation Error"
    Resume Cleanup
End Sub

' -----------------------------------------------------------------------------
' Replace this routine with the target part's complete sketch & feature steps.
' -----------------------------------------------------------------------------
Private Sub BuildPartFeatures( _
    ByVal swModel As SldWorks.ModelDoc2, _
    ByVal swFeatMgr As SldWorks.FeatureManager, _
    ByVal swSketchMgr As SldWorks.SketchManager, _
    ByRef errStep As String)

    Dim swExt As SldWorks.ModelDocExtension
    Dim swFeat As SldWorks.Feature
    Dim ok As Boolean

    Set swExt = swModel.Extension

    ' --- EXAMPLE STEP 1: Base Sketch on Front Plane (sketch XY = world XY) ---
    errStep = "Select Front Plane for Base Sketch"
    swModel.ClearSelection2 True
    ok = swExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
    If Not ok Then Err.Raise vbObjectError + 2001, "BuildPartFeatures", "Could not select Front Plane."

    swSketchMgr.InsertSketch True
    swSketchMgr.CreateCenterRectangle 0, 0, 0, MM(50), MM(30), 0

    ' Apply Smart Dimensions (width = 100 mm, height = 60 mm)
    ' Note: SelectByID2 takes 3D world coordinates (Front Plane: sketch XY = world XY)
    AddSmartDim swModel, swExt, 0, MM(30), 0, "SKETCHSEGMENT", 0, MM(45), 0, MM(100)
    AddSmartDim swModel, swExt, MM(50), 0, 0, "SKETCHSEGMENT", MM(65), 0, 0, MM(60)

    swSketchMgr.InsertSketch True

    errStep = "Create Base Extrusion"
    Set swFeat = swFeatMgr.FeatureExtrusion3( _
        True, False, False, _
        swEndConditions_e.swEndCondBlind, swEndConditions_e.swEndCondBlind, _
        MM(15), 0#, _
        False, False, False, False, 0#, 0#, _
        False, False, False, False, _
        True, True, True, _
        swStartConditions_e.swStartSketchPlane, 0#, False)
    If swFeat Is Nothing Then Err.Raise vbObjectError + 2002, "BuildPartFeatures", "Boss-Extrude1 failed."
End Sub

' -----------------------------------------------------------------------------
' Helper: Unit conversions (SOLIDWORKS API uses meters & radians)
' -----------------------------------------------------------------------------
Private Function MM(ByVal millimeters As Double) As Double
    MM = millimeters * 0.001
End Function

Private Function DegToRad(ByVal degrees As Double) As Double
    DegToRad = degrees * (PI / 180#)
End Function

' -----------------------------------------------------------------------------
' Helper: Check if a file path exists safely
' -----------------------------------------------------------------------------
Private Function FileExistsSafe(ByVal filePath As String) As Boolean
    On Error Resume Next
    If Len(Trim$(filePath)) = 0 Then
        FileExistsSafe = False
    Else
        FileExistsSafe = (Len(Dir$(filePath)) > 0)
    End If
End Function

' -----------------------------------------------------------------------------
' Helper: Create Part safely via NewDocument (avoids obsolete NewPart)
' -----------------------------------------------------------------------------
Private Function CreatePartDocSafe(ByVal swApp As SldWorks.SldWorks) As SldWorks.ModelDoc2
    Dim tmpl As String
    Dim docLocations As String
    Dim folders() As String
    Dim i As Long
    Dim candidate As String

    ' 1. Configured default Part template
    tmpl = swApp.GetUserPreferenceStringValue(swUserPreferenceStringValue_e.swDefaultTemplatePart)
    If FileExistsSafe(tmpl) Then
        Set CreatePartDocSafe = swApp.NewDocument(tmpl, 0, 0, 0)
        Exit Function
    End If

    ' 2. Configured Document Templates folder(s) (semicolon-separated)
    docLocations = swApp.GetUserPreferenceStringValue(swUserPreferenceStringValue_e.swFileLocationsDocumentTemplates)
    If Len(docLocations) > 0 Then
        folders = Split(docLocations, ";")
        For i = LBound(folders) To UBound(folders)
            candidate = Trim$(folders(i))
            If Len(candidate) > 0 Then
                If Right$(candidate, 1) <> "\" Then candidate = candidate & "\"
                If FileExistsSafe(candidate & "Part.prtdot") Then
                    Set CreatePartDocSafe = swApp.NewDocument(candidate & "Part.prtdot", 0, 0, 0)
                    Exit Function
                ElseIf FileExistsSafe(candidate & "part.prtdot") Then
                    Set CreatePartDocSafe = swApp.NewDocument(candidate & "part.prtdot", 0, 0, 0)
                    Exit Function
                End If
            End If
        Next i
    End If

    ' 3. Standard SOLIDWORKS 2026 ProgramData & Tutorial template fallbacks
    candidate = Environ$("ALLUSERSPROFILE") & "\SOLIDWORKS\SOLIDWORKS 2026\templates\Part.prtdot"
    If FileExistsSafe(candidate) Then
        Set CreatePartDocSafe = swApp.NewDocument(candidate, 0, 0, 0)
        Exit Function
    End If

    candidate = swApp.GetExecutablePath() & "\lang\english\Tutorial\part.prtdot"
    If FileExistsSafe(candidate) Then
        Set CreatePartDocSafe = swApp.NewDocument(candidate, 0, 0, 0)
        Exit Function
    End If

    Err.Raise vbObjectError + 1004, "CreatePartDocSafe", _
        "No valid SOLIDWORKS Part template (.prtdot) found. Configure Tools > Options > Default Templates."
End Function

' -----------------------------------------------------------------------------
' Helper: Select sketch entity by point and apply Smart Dimension value (meters)
' -----------------------------------------------------------------------------
Private Sub AddSmartDim( _
    ByVal swModel As SldWorks.ModelDoc2, _
    ByVal swExt As SldWorks.ModelDocExtension, _
    ByVal selX As Double, ByVal selY As Double, ByVal selZ As Double, _
    ByVal selType As String, _
    ByVal txtX As Double, ByVal txtY As Double, ByVal txtZ As Double, _
    ByVal targetMeters As Double)

    Dim dispDim As SldWorks.DisplayDimension
    Dim swDim As SldWorks.Dimension
    Dim setStatus As Long

    swModel.ClearSelection2 True
    If Not swExt.SelectByID2("", selType, selX, selY, selZ, False, 0, Nothing, 0) Then
        Err.Raise vbObjectError + 3001, "AddSmartDim", "Failed to select entity for dimensioning."
    End If

    Set dispDim = swModel.AddDimension2(txtX, txtY, txtZ)
    If dispDim Is Nothing Then
        Err.Raise vbObjectError + 3002, "AddSmartDim", "AddDimension2 returned Nothing."
    End If

    Set swDim = dispDim.GetDimension2(0)
    If swDim Is Nothing Then
        Err.Raise vbObjectError + 3003, "AddSmartDim", "GetDimension2 returned Nothing."
    End If

    setStatus = swDim.SetSystemValue3(targetMeters, swSetValueInConfiguration_e.swSetValue_InThisConfiguration, Empty)
    If setStatus <> swSetValueReturnStatus_e.swSetValue_Successful Then
        Err.Raise vbObjectError + 3004, "AddSmartDim", "SetSystemValue3 failed with status: " & setStatus
    End If

    swModel.ClearSelection2 True
End Sub

' -----------------------------------------------------------------------------
' Helper: Verify solid bodies, bounding box, and volume via GetMassProperties2
' -----------------------------------------------------------------------------
Private Sub VerifyPartGeometry(ByVal swModel As SldWorks.ModelDoc2, ByVal swPart As SldWorks.PartDoc)
    Dim vBodies As Variant
    Dim vBox As Variant
    Dim vMass As Variant
    Dim massStatus As Long
    Dim bodyCount As Long
    Dim dx As Double, dy As Double, dz As Double

    vBodies = swPart.GetBodies2(swBodyType_e.swSolidBody, True)
    If IsEmpty(vBodies) Then
        Err.Raise vbObjectError + 4001, "VerifyPartGeometry", "Model has 0 solid bodies."
    End If
    bodyCount = UBound(vBodies) - LBound(vBodies) + 1
    If bodyCount <> 1 Then
        MsgBox "Warning: Solid body count is " & bodyCount & " (expected 1 for a single-body part).", vbExclamation
    End If

    vBox = swPart.GetPartBox(True)
    dx = (vBox(3) - vBox(0)) * 1000#
    dy = (vBox(4) - vBox(1)) * 1000#
    dz = (vBox(5) - vBox(2)) * 1000#

    vMass = swModel.Extension.GetMassProperties2(1, massStatus, False)
    Debug.Print "Bodies: " & bodyCount & " | BBox (mm): " & Format(dx, "0.00") & " x " & Format(dy, "0.00") & " x " & Format(dz, "0.00")
    If massStatus = 0 And Not IsEmpty(vMass) Then
        Debug.Print "Volume (cm^3): " & Format(vMass(3) * 1000000#, "0.000")
    Else
        Debug.Print "Mass properties calculation returned status: " & massStatus
    End If
End Sub

' -----------------------------------------------------------------------------
' Helper: Create outputs\Part_XX\vNNN folder hierarchy safely in native VBA
' -----------------------------------------------------------------------------
Private Sub EnsureFolderChain(ByVal outputsRoot As String, ByVal taskFolder As String, ByVal versionFolder As String)
    Dim p1 As String, p2 As String, p3 As String
    p1 = outputsRoot
    p2 = p1 & "\" & taskFolder
    p3 = p2 & "\" & versionFolder
    If Len(Dir$(p1, vbDirectory)) = 0 Then MkDir p1
    If Len(Dir$(p2, vbDirectory)) = 0 Then MkDir p2
    If Len(Dir$(p3, vbDirectory)) = 0 Then MkDir p3
End Sub

' -----------------------------------------------------------------------------
' Helper: Save part or export STEP using SaveAs3 with explicit error checking
' -----------------------------------------------------------------------------
Private Sub SavePartSafe(ByVal swModel As SldWorks.ModelDoc2, ByVal filePath As String)
    Dim errs As Long, warns As Long
    Dim ok As Boolean

    ok = swModel.Extension.SaveAs3( _
        filePath, _
        swSaveAsVersion_e.swSaveAsCurrentVersion, _
        swSaveAsOptions_e.swSaveAsOptions_Silent, _
        Nothing, Nothing, errs, warns)

    If Not ok Then
        Err.Raise vbObjectError + 5001, "SavePartSafe", "Save failed (errors=" & errs & ", warnings=" & warns & ") at: " & filePath
    End If
End Sub

' -----------------------------------------------------------------------------
' Helper: Apply Plain Carbon Steel + Shaded With Edges when available (Tier 3)
' -----------------------------------------------------------------------------
Private Sub ApplyDefaultAppearance(ByVal swApp As SldWorks.SldWorks, ByVal swModel As SldWorks.ModelDoc2, ByVal swPart As SldWorks.PartDoc)
    On Error Resume Next
    Dim exeDir As String
    Dim matDb As String
    Dim mv As SldWorks.ModelView
    exeDir = swApp.GetExecutablePath()
    If Len(exeDir) > 0 And Right$(exeDir, 1) <> "\" Then exeDir = exeDir & "\"
    matDb = exeDir & "lang\english\sldmaterials\solidworks materials.sldmat"
    If FileExistsSafe(matDb) Then
        swPart.SetMaterialPropertyName2 "", matDb, "Plain Carbon Steel"
    End If
    Set mv = swModel.ActiveView
    If Not mv Is Nothing Then
        mv.DisplayMode = swViewDisplayMode_e.swViewDisplayMode_ShadedWithEdges
    End If
    On Error GoTo 0
End Sub
