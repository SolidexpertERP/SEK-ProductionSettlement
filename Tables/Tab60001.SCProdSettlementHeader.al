table 60001 "SC Prod.Settlement Header"
{

    Caption = 'Nagłówek dokumentu rozliczenia produkcji';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'Nr dokumentu';
        }
        field(2; Status; enum "SC Prod. Settl. Header Status")
        {
        }
        field(3; "Document Date"; Date)
        {
            Caption = 'Data dokumentu';
        }
        field(4; "User Name"; Text[250])
        {
            Caption = 'Użytkownik';
        }
        field(5; Month; Integer)
        {
            Caption = 'Miesiąc';
            MaxValue = 12;
            MinValue = 1;

            trigger OnValidate()
            begin
                UpdateDates;
            end;
        }
        field(6; Year; Integer)
        {
            Caption = 'Rok';
            MaxValue = 2999;
            MinValue = 2000;

            trigger OnValidate()
            begin
                UpdateDates;
            end;
        }
        field(7; "Settlement Type"; Enum "SC Settlement Type")
        {
            Caption = 'Typ rozliczenia';

            trigger OnValidate()
            begin
                IF Status.AsInteger() > Status::"Lines Generated".AsInteger() THEN
                    ERROR('Nie można zmienić typu rozliczenia w statusie Przeksięgowane');

                AskForChanges(FIELDCAPTION("Settlement Type"));
            end;
        }
        field(8; "Document Type"; Enum "SC Document Type")
        {
            Caption = 'Typ dokumentu';

        }
        field(100; "Date From"; Date)
        {
            Caption = 'Data od';
        }
        field(101; "Date To"; Date)
        {
            Caption = 'Data do';
        }
        field(102; "G/L Account Filter"; Text[250])
        {
            Caption = 'Filtr konta K/G';
        }
        field(103; "MKP Dim Filter"; Text[250])
        {
            Caption = 'Filtr wymiaru MPK';
        }
        field(104; "KALKULACJA Dim Filter"; Text[250])
        {
            Caption = 'Filtr wymiaru KALKULACJA';
        }
        field(105; "Fixed Costs Dim Value"; Code[10])
        {
            Caption = 'Wartość wym. dla kosztów stałych';
        }
        field(106; "Variable Costs Dim Value"; Code[10])
        {
            Caption = 'Wartość wym. dla kosztów zmiennych';
        }
        field(107; "Fixed Cost Item"; Code[20])
        {
            Caption = 'Zapas kosztów stałych';
            TableRelation = Item;
        }
        field(108; "Variable Cost Item"; Code[20])
        {
            Caption = 'Zapas kosztów zmiennych';
            TableRelation = Item;
        }
        field(109; "PROJEKT Dim Filter"; Text[250])
        {
            Caption = 'Filtr wymiaru PROJEKT';
        }
        field(110; "Work Type Code Filter"; Text[250])
        {
            Caption = 'Filtr Kodu typu prac';

            trigger OnLookup()
            var
                WorkTypes: Page "Work Types";
                WorkType: Record "Work Type";
            begin
                WorkType.RESET;
                CLEAR(WorkTypes);
                WorkTypes.LOOKUPMODE(TRUE);
                IF WorkTypes.RUNMODAL IN [ACTION::LookupOK, ACTION::OK] THEN BEGIN
                    WorkTypes.GETRECORD(WorkType);

                    IF "Work Type Code Filter" = '' THEN
                        "Work Type Code Filter" := WorkType.Code
                    ELSE
                        "Work Type Code Filter" += '|' + WorkType.Code;
                END;
            end;
        }
        field(111; "Account No. (6*)"; Code[20])
        {
            Caption = 'Nr konta (6*)';
            Description = '003.168';
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                 Blocked = CONST(false));
        }
        field(112; "Account No. (4*)"; Code[20])
        {
            Caption = 'Nr konta (4*)';
            Description = '003.168';
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                 Blocked = CONST(false));
        }
        field(113; "Account No. (7*)"; Code[20])
        {
            Caption = 'Nr konta (7*)';
            Description = '003.168';
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                 Blocked = CONST(false));
        }
        field(114; Description; Text[220])
        {
            Caption = 'Opis';
            Description = '003.168';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ProdSettlSourceLines: Record "SC Prod. Settl. Source Line";
    begin
        ProdSettlSourceLines.RESET;
        ProdSettlSourceLines.SETRANGE("Document No.", Rec."No.");
        ProdSettlSourceLines.DELETEALL;
    end;

    trigger OnInsert()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        IF (Rec.Year = 0) OR (Rec.Month = 0) AND ("Date From" = 0D) THEN
            ERROR('Uzupełnij wymagane pola: Miesiąc, Rok')
    end;

    local procedure UpdateDates()
    var
        data: Date;
    begin
        IF Month = 0 THEN
            EXIT;

        IF Year = 0 THEN
            EXIT;

        data := DMY2DATE(1, Month, Year);

        "Date From" := CALCDATE('<-CM>', data);
        "Date To" := CALCDATE('<CM>', data);

        GenerateNo(TRUE);
    end;

    local procedure DeleteAllData()
    var
        ProdSettlSourceLines: Record "SC Prod. Settl. Source Line";
        ProdSettlSummaryLines: Record "SC Prod. Settl. Summary Lines";
    begin
        ProdSettlSummaryLines.RESET;
        ProdSettlSummaryLines.SETRANGE("Document No.", "No.");
        ProdSettlSummaryLines.DELETEALL(TRUE);

        ProdSettlSourceLines.RESET;
        ProdSettlSourceLines.SETRANGE("Document No.", "No.");
        ProdSettlSourceLines.DELETEALL(TRUE);

        Status := Status::New;
    end;

    local procedure AskForChanges(_FieldCaption: Text)
    begin
        IF CONFIRM('Czy na pewno chcesz zmienić wartość pola %1? Spowoduje to usunięcie wszystkich wygenerowanych danych', FALSE, _FieldCaption) THEN
            DeleteAllData
        ELSE
            ERROR('');
    end;


    procedure GenerateNo(_Insert: Boolean)
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        ManufacturingSetup: Record "Manufacturing Setup";
        NewNo: Code[20];
        EmptyCode: Code[10];
        AssemblySetup: Record "Assembly Setup";
        NosCode: Code[10];
        JobsSetup: Record "Jobs Setup";
    begin
        CLEAR(NewNo);
        CLEAR(EmptyCode);
        CLEAR(NosCode);

        CASE Rec."Settlement Type" OF

            Rec."Settlement Type"::Production:
                BEGIN
                    ManufacturingSetup.GET;
                    ManufacturingSetup.TESTFIELD("Prod. Settl. Cost Nos.");
                    NosCode := ManufacturingSetup."Prod. Settl. Cost Nos.";
                END;

            Rec."Settlement Type"::Assembly:
                BEGIN
                    AssemblySetup.GET;
                    AssemblySetup.TESTFIELD("Assembly Settl. Cost Nos.");
                    NosCode := AssemblySetup."Assembly Settl. Cost Nos.";
                END;

            Rec."Settlement Type"::Job:
                BEGIN
                    JobsSetup.GET;
                    JobsSetup.TESTFIELD("Job Settl. Cost Nos.");
                    NosCode := JobsSetup."Job Settl. Cost Nos.";
                END;
        END;
        IF _Insert THEN
            NoSeriesManagement.InitSeries(NosCode, NosCode, "Date From", NewNo, EmptyCode)
        ELSE
            NewNo := NoSeriesManagement.GetNextNo(NosCode, "Date From", FALSE);

        Rec.VALIDATE("No.", NewNo);
    end;

    procedure CheckDate(DateFrom: Date): Boolean
    begin
        IF DateFrom <> 0D THEN
            EXIT(FALSE)
        ELSE
            EXIT(TRUE);
    end;
}

