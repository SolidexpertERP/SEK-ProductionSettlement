table 60003 "SC Account No. - MPK Code"
{
    Caption = 'MPK - Nr kont do rozliczenia';

    fields
    {
        field(1; "MPK Dimension"; Code[20])
        {
            Caption = 'Kod MPK';
            Description = '003.168';
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = CONST('MPK'),
                                                          Blocked = CONST(false));
        }
        field(2; "Work Type Code"; Code[10])
        {
            Caption = 'Kod typu prac';
            Description = '003.168';
            TableRelation = "Work Type".Code;
        }
        field(3; "Account No. 6"; Code[20])
        {
            Caption = 'Nr konta grupy 6';
            Description = '003.168';
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                 Blocked = CONST(false));
        }
        field(4; "Account No. 4"; Code[20])
        {
            Caption = 'Nr konta grupy 4';
            Description = '003.168';
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                 Blocked = CONST(false));
        }
        field(5; "Account No. 7"; Code[20])
        {
            Caption = 'Nr konta grupy7';
            Description = '003.168';
            TableRelation = "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                 Blocked = CONST(false));
        }
    }

    keys
    {
        key(Key1; "MPK Dimension", "Work Type Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

