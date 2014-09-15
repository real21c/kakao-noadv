unit unitKakao;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ShellAPI, Registry;

type
  TfrmRemoveKakaoAD = class(TForm)
    tmrURL: TTimer;
    lblResult: TLabel;
    lblMy: TLabel;
    lblTitle: TLabel;
    procedure tmrURLTimer(Sender: TObject);
    procedure lblMyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure CheckURL;
    function getInstallDir: string;
  end;

var
  frmRemoveKakaoAD: TfrmRemoveKakaoAD;
  friendList,
  childAD: HWND;
  //titleAD: array[0..255] of Char;

implementation

{$R *.dfm}

//HKEY_CLASSES_ROOT\TypeLib\{B694121F-57B7-4F4D-9B07-0464BE376A1C}
function TfrmRemoveKakaoAD.getInstallDir: string;
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CLASSES_ROOT;
  if reg.OpenKey('TypeLib\{B694121F-57B7-4F4D-9B07-0464BE376A1C}\1.0\HELPDIR', false) then begin
    result := reg.ReadString('');
    reg.CloseKey;
  end;
  FreeAndNil(reg);
end;

function EnumWindowsProc(Handle: HWND):Bool; stdcall;
var
  ClassName: string;
  Title: array[0..255] of Char;
  Rect: TRect;
begin
  if IsWindowVisible(Handle) and ((GetWindowLong(Handle, WS_EX_DLGMODALFRAME) = 0)) then begin
        SetLength (ClassName, 100);
        GetClassName (Handle, PChar (ClassName), Length (ClassName));
        ClassName := PChar (ClassName);
        GetWindowText(Handle, Title, 255);

        if ClassName = '#32770' then begin
          if (Title = '카카오톡') then begin
              GetWindowRect(Handle, Rect);

              friendList :=  FindWindowEx(Handle, 0, '#32770', nil);
              childAD := FindWindowEx(Handle, 0, 'EVA_Window', nil);

              //GetWindowText(childAD, titleAD, 255);

              if (childAD > 0) then begin
                showWindow(childAD, SW_HIDE);
                SetWindowPos(childAD, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE);
                SetWindowPos(friendList, HWND_BOTTOM, 0, 0, (Rect.Right - Rect.Left), (Rect.Bottom - Rect.Top - 36), SWP_NOMOVE);
                frmRemoveKakaoAD.lblResult.Caption := '광고가 제거되었습니다.';
              end;
          end;
        end;
    end;
end;

procedure TfrmRemoveKakaoAD.tmrURLTimer(Sender: TObject);
begin
  CheckUrl;
  
end;

procedure TfrmRemoveKakaoAD.CheckUrl;
begin
  tmrUrl.Enabled := False;

  try
    EnumWindows(@EnumWindowsProc, 1);
  except
  end;

  tmrUrl.Enabled := True;
end;

procedure TfrmRemoveKakaoAD.lblMyClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://twitter.com/real21c', nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmRemoveKakaoAD.FormCreate(Sender: TObject);
var
  kakaoPath: string;
begin
  kakaoPath := getInstallDir;
  ShellExecute(0, 'open', PChar(kakaoPath + '\KakaoTalk.exe'), nil, nil, SW_SHOWNORMAL);
end;

end.
