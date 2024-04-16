tableextension 70132 "SC Manufacturing Setup" extends "Manufacturing Setup"
{
    fields
    {
        field(60000; "Prod. Settl. Cost Nos."; Code[10])
        {
            Caption = 'Seria numeracji rozliczania produkcji';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
    }
}
