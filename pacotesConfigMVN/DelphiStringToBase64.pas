procedure TForm1.Button1Click(Sender: TObject);
var
    MStream:TMemoryStream;
    Decoder:TIdDecoderMIME;
    Base64: string;
begin
    Decoder := TIdDecoderMIME.Create(nil);
    MStream := TMemoryStream.Create;
    Base64 := LerArquivo();

    try
        Decoder.DecodeBegin(MStream);
        Decoder.Decode(Base64);
        Decoder.DecodeEnd;
    finally
        Decoder.Free;
    end;

    try
        MStream.SaveToFile('C:\bases\example.pdf');
    finally
        FreeAndNil(MStream);
    end;
end;

function LerArquivo(): String;
var
    base64File : TextFile;
    base64String: String;
    line: String;
begin
    AssignFile(base64File, 'C:\bases\razao64.txt');
    Reset(base64File);
    base64String := '';

    while not Eof(base64File) do
    begin
        ReadLn(base64File, line);
        base64String := base64String + line;
    end;

    CloseFile(base64File);

    Result := base64String;
end;
--------------------------------------------------------------------------------------------------------------------------------------------
procedure TF_ManutDFeCTe.ImprimirCTe;
var
    cteResposta: TCteResposta;
    base64: string;
begin
    if CTeChave<>'' then
    begin
        base64:='SIM';

        if FileExists(DM.Img+'\CTe\'+CTeChave+'-procCTe.pdf') then
            ShellExecute(0, nil, PChar(DM.Img+'\CTe\'+CTeChave+'-procCTe.pdf'), nil, nil, SW_SHOWNORMAL)
        else
        begin
            cteResposta:=gerarPdfCTe(CTeChave, '', DM.Token, DM.Schema, DM.IpPorta, base64);

            if cteResposta.reportStatus=ERROR then
                ShowMessage(cteResposta.reportErrorMessage)
            else
            begin
                if (base64='SIM') then
                begin
                    base64ToFile(cteResposta.xmlBase64File, PChar(DM.Img+'\CTe\'+CTeChave+'-procCTe.xml'));
                    base64ToFile(cteResposta.pdfBase64File, PChar(DM.Img+'\CTe\'+CTeChave+'-procCTe.pdf'));
                end;

                ShellExecute(0, nil, PChar(DM.Img+'\CTe\'+CTeChave+'-procCTe.pdf'), nil, nil, SW_SHOWNORMAL);
            end;
        end;
    end;
end;
--------------------------------------------------------------------------------------------------------------------------------------------
procedure TF_ManutDFeCTeOS.ImprimirCTeOS;
var
    cteResposta: TCteResposta;
    base64: string;
begin
    if FileExists(DM.Img+'\CTeOS\'+CTeOSChave+'-procCTe.pdf') then
        ShellExecute(0, nil, PChar(DM.Img+'\CTeOS\'+CTeOSChave+'-procCTe.pdf'), nil, nil, SW_SHOWNORMAL)
    else
    begin
        base64:='SIM';

        cteResposta:=gerarPdfCTeOS(CTeOSChave, '', DM.Token, DM.Schema, DM.IpPorta, base64);

        if cteResposta.reportStatus=ERROR then
            ShowMessage(cteResposta.reportErrorMessage)
        else
        begin
            if (base64='SIM') then
            begin
                base64ToFile(cteResposta.xmlBase64File, PChar(DM.Img+'\CTeOS\'+CTeOSChave+'-procCTe.xml'));
                base64ToFile(cteResposta.pdfBase64File, PChar(DM.Img+'\CTeOS\'+CTeOSChave+'-procCTe.pdf'));
            end;

            ShellExecute(0, nil, PChar(DM.Img+'\CTeOS\'+CTeOSChave+'-procCTe.pdf'), nil, nil, SW_SHOWNORMAL);
        end;
    end;
end;
--------------------------------------------------------------------------------------------------------------------------------------------
procedure base64ToFile(base64:string; arquivo:string);
procedure base64ToFile(base64:string; arquivo:string);
var
    MStream:TMemoryStream;
    Decoder:TIdDecoderMIME;
begin
    Decoder := TIdDecoderMIME.Create(nil);
    MStream := TMemoryStream.Create;

    try
        Decoder.DecodeBegin(MStream);
        Decoder.Decode(base64);
        Decoder.DecodeEnd;
    finally
        FreeAndNil(Decoder);
    end;

    try
        MStream.SaveToFile(arquivo);
    finally
        FreeAndNil(MStream);
    end;
end;
--------------------------------------------------------------------------------------------------------------------------------------------
function gerarPdfCTeOS(chave:string; email: string; token:string; schema:string; endereco:string; base64:string):TCteResposta;
var
    httpClient: TIdHTTP;
    json: TStream;
    jsonResultString: String;
    cteResposta: TCteResposta;
begin
    try
        httpClient := criarHttpClient(token, schema, 'read');
        json := TStringStream.Create('{"chave":"'+chave+'","email":"'+email+'", "base64":"'+base64+'"}');
        jsonResultString := Utf8Decode(httpClient.Post('http://'+endereco+'/cte/imprimir/os', json));

        Result:= parseRespostaCte(jsonResultString, True);
    except
        on E : Exception do
        begin
            cteResposta := TCteResposta.Create;
            cteResposta.status:=ERROR;
            cteResposta.errorMessage:=E.Message;

            Result:= cteResposta;
        end;
    end;
    httpClient.Free;
end;
--------------------------------------------------------------------------------------------------------------------------------------------
function gerarPdfCTe(chave:string; email: string; token:string; schema:string; endereco:string; base64:string):TCteResposta;
var
    httpClient: TIdHTTP;
    json: TStream;
    jsonResultString: String;
    cteResposta: TCteResposta;
begin
    try
        httpClient := criarHttpClient(token, schema, 'read');
        json := TStringStream.Create('{"chave":"'+chave+'","email":"'+email+'", "base64":"'+base64+'"}');
        jsonResultString := Utf8Decode(httpClient.Post('http://'+endereco+'/cte/imprimir/', json));

        Result:= parseRespostaCte(jsonResultString, True);
    except
        on E : Exception do
        begin
            cteResposta := TCteResposta.Create;
            cteResposta.status:=ERROR;
            cteResposta.errorMessage:=E.Message;

            Result:= cteResposta;
        end;
    end;
    httpClient.Free;
end;
--------------------------------------------------------------------------------------------------------------------------------------------
function parseRespostaCte(jsonString:string; nota:Boolean) : TCteResposta;
var
    json: TlkJSONobject;
    resposta: TCteResposta;
    status: Variant;
    xmlBase64File: Variant;
    pdfBase64File: Variant;
begin
    json := TlkJSON.ParseText(jsonString) as TlkJSONobject;
    resposta := TCteResposta.Create;

    resposta.status := TResponseStatus(GetEnumValue(TypeInfo(TResponseStatus), json.Field['status'].Value));
    resposta.errorMessage := parseField(json, 'errorMessage');

    if resposta.status=OK then
    begin
        resposta.cteStatus := TResponseStatus(GetEnumValue(TypeInfo(TResponseStatus), json.Field['cteStatus'].Value));

        if resposta.cteStatus=OK then
        begin
            status := parseField(json, 'reportStatus');

            if VarIsStr(status) then
            begin
                resposta.reportStatus := TResponseStatus(GetEnumValue(TypeInfo(TResponseStatus), status));
                resposta.reportErrorMessage := parseField(json, 'reportErrorMessage');

                if resposta.reportStatus=OK then
                begin
                    resposta.reportPath := parseField(json, 'reportPath');
                    resposta.xmlPath := parseField(json, 'xmlPath');

                    status := json.Field['mailStatus'].Value;

                    if VarIsStr(status) then
                    begin
                        resposta.mailStatus := TResponseStatus(GetEnumValue(TypeInfo(TResponseStatus), status));
                        resposta.mailErrorMessage := parseField(json, 'mailErrorMessage');
                    end;
                end;
            end;

            ///// AQUIIIII
            resposta.xmlBase64File := parseField(json, 'xmlBase64File');
            resposta.pdfBase64File := parseField(json, 'pdfBase64File');
        end;
--------------------------------------------------------------------------------------------------------------------------------------------
procedure TF_ManutDFeNFSe.ImprimirNFSe;
var
    NfseResposta: TNFSeResposta;
    NomeArquivo: String;
    NomeArquivoXml: String;
    base64: string;
begin
    base64:='SIM';

    DM.IBQ_Aux.SQL.Clear;
    DM.IBQ_Aux.SQL.Add('select (select ibge from cidade where cidade=F.cidade) as ibge, imunicipal from filial F where F.empresa='+IntToStr(DM.Empresa)+' and F.filial='+IntToStr(DM.Filial));
    DM.IBQ_Aux.Active := True;

    if CidadeNFSe='ARROIO_DO_MEIO' then
    begin
        NomeArquivo:=DM.Img+'\NFSe\nfse_'+IntToStr(NumeroNFSe-1000000)+'_'+IntToStr(DM.Filial)+'.pdf';
        NomeArquivoXml:=DM.Img+'\NFSe\nfse_'+IntToStr(NumeroNFSe-1000000)+'_'+IntToStr(DM.Filial)+'.xml';
    end
    else
    begin
        NomeArquivo:=DM.Img+'\NFSe\nfse_'+IntToStr(NumeroNFSe)+'_'+IntToStr(DM.Filial)+'.pdf';
        NomeArquivoXml:=DM.Img+'\NFSe\nfse_'+IntToStr(NumeroNFSe)+'_'+IntToStr(DM.Filial)+'.xml';
    end;

    NfseResposta:=gerarPdfNfse(DM.Token, DM.Schema, DM.IpPorta, CidadeNFSe, LimpaNumero(DM.IFederal), 'LOTE_'+IntToStr(NumeroNFSe), IntToStr(RG_Ambiente.ItemIndex+1), LimpaNumero(DM.IBQ_Aux.FieldValues['IMUNICIPAL']), 'ranieri@flexabus.com.br', base64);
    if NfseResposta.statusReport=ERROR then
        ShowMessage(NfseResposta.errorMessageReport);

    if (NfseResposta.linkPdf<>'')and(NfseResposta.linkPdf<>Variants.Null) then
        ShellExecute(0, 'open', PChar(NfseResposta.linkPdf), nil, nil, SW_SHOWNORMAL)
    else
    begin
        if (base64='SIM') then
        begin
            base64ToFile(NfseResposta.xmlBase64File, NomeArquivoXml);
            base64ToFile(NfseResposta.pdfBase64File, NomeArquivo);
        end;

        if FileExists(NomeArquivo) then
            ShellExecute(0, nil, PChar(NomeArquivo), nil, nil, SW_SHOWNORMAL);
    end;
end;
--------------------------------------------------------------------------------------------------------------------------------------------
function gerarPdfNfse(token:string; schema:string; endereco:string; cidade:string; cnpj:string; lote:string; tpAmb:string; incricaoMunicipal:string; email:string; base64:string):TNFSeResposta;
var
    httpClient: TIdHTTP;
    data: String;
    json: TStream;
    jsonResultString: String;
    nfseResposta: TNFSeResposta;
begin
    try
        try
            httpClient := criarHttpClient(token, schema, 'create');
            data := '{"cidade":"'+cidade+'","cnpj":"'+cnpj+'","lote":"'+lote+'","tpAmb":"'+tpAmb+'","inscricaoMunicipal":"'+incricaoMunicipal
                    +'", "email":"'+email+'", "base64":"'+base64+'"}';
            json := TStringStream.Create(data);
            jsonResultString := Utf8Decode(httpClient.Post('http://'+endereco+'/nfse/imprimir', json));

            Result:= parseRespostaNfse(jsonResultString, False);
        except
            on E : Exception do
            begin
                nfseResposta := TNFSeResposta.Create;
                nfseResposta.status:=ERROR;
                nfseResposta.errorMessage:=E.Message;

                Result:= nfseResposta;
            end;
        end;
    finally
        httpClient.Free;
    end;
end;
--------------------------------------------------------------------------------------------------------------------------------------------
function parseRespostaNfse(jsonString:string; nota:Boolean) : TNFSeResposta;
var
    json: TlkJSONobject;
    resposta: TNFSeResposta;
    status: Variant;
begin
    json := TlkJSON.ParseText(jsonString) as TlkJSONobject;
    resposta := TNFSeResposta.Create;

    resposta.status := TResponseStatus(GetEnumValue(TypeInfo(TResponseStatus), json.Field['status'].Value));
    resposta.errorMessage := parseField(json, 'errorMessage');

    if resposta.status=OK then
    begin
        resposta.statusNfse := TResponseStatus(GetEnumValue(TypeInfo(TResponseStatus), json.Field['statusNfse'].Value));
        resposta.nfseMessage := parseField(json, 'nfseMessage');

        if resposta.statusNfse=OK then
        begin
            resposta.statusReport := TResponseStatus(GetEnumValue(TypeInfo(TResponseStatus), json.Field['statusReport'].Value));
            resposta.errorMessageReport := parseField(json, 'errorMessageReport');
            resposta.numeroFiscal := parseField(json, 'numeroFiscal');

            if resposta.statusReport=OK then
            begin
                resposta.linkPdf := parseField(json, 'linkPdf');
                status := json.Field['statusMail'].Value;

                if VarIsStr(status) then
                begin
                    resposta.statusMail := TResponseStatus(GetEnumValue(TypeInfo(TResponseStatus), status));
                    resposta.errorMessageMail := parseField(json, 'errorMessageMail');
                end;
            end;
        end;

        resposta.xmlBase64File := parseField(json, 'xmlBase64File');
        resposta.pdfBase64File := parseField(json, 'pdfBase64File');
    end;

    Result:= resposta;
end;
--------------------------------------------------------------------------------------------------------------------------------------------
    FxmlBase64File:string;
    FpdfBase64File:string;

    property xmlBase64File: string read FxmlBase64File write FxmlBase64File;
    property pdfBase64File: string read FpdfBase64File write FpdfBase64File;

    --- TNFSeResposta
    --- TCteResposta

--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
