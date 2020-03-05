page 50141 SalesInvoiceCopy
{
    ODataKeyFields = "Id";
    SourceTable = "Sales Header";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(Id; Id)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        SetRange("Document Type", "Document Type"::Invoice);
    end;

    [ServiceEnabled]
    procedure Copy(var actionContext: WebServiceActionContext)
    var
        FromSalesHeader: Record "Sales Header";
        ToSalesHeader: Record "Sales Header";
        SalesSetup: Record "Sales & Receivables Setup";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        DocType: Option Quote,"Blanket Order",Order,Invoice,"Return Order","Credit Memo","Posted Shipment","Posted Invoice","Posted Return Receipt","Posted Credit Memo";
    begin
        SalesSetup.Get;
        CopyDocMgt.SetProperties(true, false, false, false, false, SalesSetup."Exact Cost Reversing Mandatory", false);

        FromSalesHeader.Get("Document Type", "No.");
        ToSalesHeader."Document Type" := FromSalesHeader."Document Type";
        ToSalesHeader.Insert(true);

        CopyDocMgt.CopySalesDoc(DocType::Invoice, FromSalesHeader."No.", ToSalesHeader);

        actionContext.SetObjectType((ObjectType::Page));
        actionContext.SetObjectId(Page::SalesInvoiceCopy);
        actionContext.AddEntityKey(Rec.FieldNo(Id), ToSalesHeader.Id);

        // Set the result code to inform the caller that an item was created
        actionContext.SetResultCode(WebServiceActionResultCode::Created);
    end;
}