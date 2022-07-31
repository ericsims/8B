Procedure GenerateOutputFiles(ProjectFilePath : String);
Var
    WS            : IWorkspace;
    Prj           : IProject;
    Document      : IServerDocument;
Begin
    // Set the Project file path
    //ProjectFilePath := 'D:\Users\erics\Documents\16B\ALU_Ctrl\ALU_Ctrl.PrjPcb';

    // Reset all parameters
    ResetParameters;

    // Open the project
    AddStringParameter('ObjectKind','Project');
    AddStringParameter('FileName', ProjectFilePath);
    RunProcess('WorkspaceManager:OpenObject');
    ResetParameters;

    // Requirement: OutJob file name is Build.OutJob and is exists within the project
    Document := Client.OpenDocument('OUTPUTJOB', ExtractFilePath(ProjectFilePath) + 'Build.OutJob');


    If Document <> Nil Then
    Begin
        WS := GetWorkspace;
        If WS <> Nil Then
        Begin
            Prj := WS.DM_FocusedProject;
            If Prj <> Nil Then
            Begin
                // Compile the project
                Prj.DM_Compile;
                Client.ShowDocument(Document);

                // Run Output Job
                ResetParameters;
                AddStringParameter('Action',            'PublishToPDF');
                AddStringParameter('ObjectKind',        'OutputBatch');
                AddStringParameter ('DisableDialog',    'True');
                AddStringParameter ('OpenOutput',       'False');
                AddStringParameter ('PromptOverwrite',  'False');
                RunProcess('WorkSpaceManager:Print');

                ResetParameters;
                AddStringParameter('Action',            'Run');
                AddStringParameter('OutputMedium',      'Mechanical');
                AddStringParameter('ObjectKind',        'OutputBatch');
                RunProcess('WorkSpaceManager:GenerateReport');

                ResetParameters;
                AddStringParameter('Action',            'Run');
                AddStringParameter('OutputMedium',      'PCB_Files');
                AddStringParameter('ObjectKind',        'OutputBatch');
                RunProcess('WorkSpaceManager:GenerateReport');
            End;
        End;
    End;

    // Close all objects
    ResetParameters;
    AddStringParameter('ObjectKind', 'FocusedProjectDocuments');
    RunProcess('WorkspaceManager:CloseObject');

    // Close Altium Designer
    //TerminateWithExitCode(0);
End;
