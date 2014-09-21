unit unitKakao;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ShellAPI, Registry, jpeg;

type
  TfrmRemoveKakaoAD = class(TForm)
    tmrURL: TTimer;
    Panel2: TPanel;
    Label4: TLabel;
    lblUI_Min: TLabel;
    lblUI_Close: TLabel;
    tmrClose: TTimer;
    Panel1: TPanel;
    lblResult1: TLabel;
    lblResult2: TLabel;
    Shape1: TShape;
    lblResult3: TLabel;
    lblState1: TLabel;
    lblState2: TLabel;
    lblState3: TLabel;
    lblMy: TLabel;
    Label1: TLabel;
    lblVersion: TLabel;
    procedure tmrURLTimer(Sender: TObject);
    procedure lblMyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure lblUI_CloseClick(Sender: TObject);
    procedure lblUI_MinClick(Sender: TObject);
    procedure lblUI_MinMouseLeave(Sender: TObject);
    procedure lblUI_MinMouseEnter(Sender: TObject);
    procedure tmrCloseTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    mousePoint:TPoint;
    second: Integer;
    procedure CheckURL;
    procedure setDeactiveControl(Sender: TLabel);
    procedure setActiveControl(Sender: TLabel);
    procedure setStateProgress(Sender: TLabel);
    procedure setStateCompleted(Sender: TLabel);
    function getInstallDir: string;
  end;

const
  TERMINATE_SECOND  = 10;
  TERMINATE_MESSAGE = '%d초 후 프로그램을 종료합니다.';

  COLOR_ACTIVE    = $00535272; // RGB(114, 82, 83);
  COLOR_DEACTIVE  = $00C6C5D6; // RGB(214, 197, 198);


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
                if frmRemoveKakaoAD.tmrClose.Enabled = False then begin

                  frmRemoveKakaoAD.setStateCompleted(frmRemoveKakaoAD.lblState1);
                  frmRemoveKakaoAD.setActiveControl(frmRemoveKakaoAD.lblResult2);
                  frmRemoveKakaoAD.tmrClose.Enabled := True;
                  //frmRemoveKakaoAD.lblResult2.Caption := '광고가 제거되었습니다.';
                end;
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


procedure TfrmRemoveKakaoAD.FormCreate(Sender: TObject);
var
  kakaoPath: string;
begin
  setActiveControl(lblResult1);
  setStateProgress(lblState1);
  lblResult3.Caption := StringReplace(TERMINATE_MESSAGE, '%d', IntToStr(TERMINATE_SECOND), [rfReplaceAll]);

  kakaoPath := getInstallDir;
  ShellExecute(0, 'open', PChar(kakaoPath + '\KakaoTalk.exe'), nil, nil, SW_SHOWNORMAL);
  setStateProgress(lblState2);
end;

procedure TfrmRemoveKakaoAD.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmRemoveKakaoAD.FormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  If button = mbleft then begin
    mousePoint.X := X;
    mousePoint.Y := Y;
  end;
end;

procedure TfrmRemoveKakaoAD.FormMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if ssLeft in Shift then begin
    Self.Left := Self.Left - (mousePoint.X - X);
    Self.Top := Self.Top - (mousePoint.Y - Y);
  end;
end;

procedure TfrmRemoveKakaoAD.lblUI_MinClick(Sender: TObject);
begin
  Self.WindowState := wsMinimized;
end;

procedure TfrmRemoveKakaoAD.lblUI_CloseClick(Sender: TObject);
begin
  Close
end;

procedure TfrmRemoveKakaoAD.lblUI_MinMouseLeave(Sender: TObject);
begin
  TLabel(Sender).Font.Color := clSilver;
end;

procedure TfrmRemoveKakaoAD.lblUI_MinMouseEnter(Sender: TObject);
begin
  TLabel(Sender).Font.Color := clWhite;
end;

procedure TfrmRemoveKakaoAD.lblMyClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'http://real21c.com/kakaoNoAdv', nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmRemoveKakaoAD.tmrCloseTimer(Sender: TObject);
begin
  setStateCompleted(lblState2);
  setStateProgress(lblState3);
  setActiveControl(lblResult3);

  second := second + 1;
  lblResult3.Caption := StringReplace(TERMINATE_MESSAGE, '%d', IntToStr(TERMINATE_SECOND + 1 - second), [rfReplaceAll]);
  if second >= TERMINATE_SECOND + 1 then begin
    close;
  end;
end;

procedure TfrmRemoveKakaoAD.setActiveControl(Sender: TLabel);
begin
  setDeactiveControl(lblResult1);
  setDeactiveControl(lblResult2);
  setDeactiveControl(lblResult3);

  Sender.Font.Style := [fsBold];
  Sender.Font.Color := COLOR_ACTIVE;
end;

procedure TfrmRemoveKakaoAD.setDeactiveControl(Sender: TLabel);
begin
  Sender.Font.Style := [];
  Sender.Font.Color := COLOR_DEACTIVE;
end;

procedure TfrmRemoveKakaoAD.setStateProgress(Sender: TLabel);
begin
  sender.Caption := ' →';
  Sender.Visible := True;
  Sender.Font.Color := COLOR_ACTIVE;
end;

procedure TfrmRemoveKakaoAD.setStateCompleted(Sender: TLabel);
begin
  sender.Caption := 'OK';
  Sender.Visible := True;
  Sender.Font.Color := COLOR_DEACTIVE;
end;


end.
