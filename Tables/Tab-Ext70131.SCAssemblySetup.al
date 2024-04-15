tableextension 70131 "SC Assembly Setup" extends "Assembly Setup"
{
    fields
    {
        field(60000; "Assembly Settl. Cost Nos."; Code[10])
        {
            Caption = 'Seria num. rozliczania kosztu kompletacji';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
    }
}
