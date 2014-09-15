program KakaoPC_NoAdv;

uses
  Forms,
  unitKakao in 'unitKakao.pas' {frmRemoveKakaoAD};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmRemoveKakaoAD, frmRemoveKakaoAD);
  Application.Run;
end.
