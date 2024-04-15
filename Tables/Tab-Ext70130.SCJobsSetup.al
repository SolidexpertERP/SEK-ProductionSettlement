tableextension 70130 "SC Jobs Setup" extends "Jobs Setup"
{
    fields
    {
        field(60000; "Job Settl. Cost Nos."; Code[10])
        {
            Caption = 'Seria numeracji rozliczania kosztu zleceń';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
    }
}
