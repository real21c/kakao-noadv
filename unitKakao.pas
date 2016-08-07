{*******************************************************}
{                                                       }
{  카카오톡 PC버전 광고 제거 프로그램입니다.            }
{                                                       }
{  개발자: 김동민                                       }
{  연락처: real21c@gmail.com                            }
{                                                       }
{  http://real21c.com/kakao-noadv                       }
{                                                       }
{*******************************************************}
unit unitKakao;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ShellAPI, Registry;

type
  TfrmRemoveKakaoAD = class(TForm)
    tmrURL: TTimer;
    tmrClose: TTimer;
    panelTop: TPanel;
    panelClient: TPanel;
    lblAppTitle: TLabel;
    lblVersion: TLabel;
    lblUI_Min: TLabel;
    lblUI_Close: TLabel;
    lblResult1: TLabel;
    lblResult2: TLabel;
    lblResult3: TLabel;
    lblState1: TLabel;
    lblState2: TLabel;
    lblState3: TLabel;
    lblUpdate: TLabel;
    lblReal21c: TLabel;
    shapeLine: TShape;
    procedure tmrURLTimer(Sender: TObject);
    procedure lblReal21cClick(Sender: TObject);
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
  TERMINATE_MESSAGE = '%d초 후 프로그램을 종료합니다.';
  TERMINATE_SECOND  = 5;
  COLOR_ACTIVE      = $00535272; // RGB(114, 82, 83);
  COLOR_DEACTIVE    = $00C6C5D6; // RGB(214, 197, 198);

var
  frmRemoveKakaoAD: TfrmRemoveKakaoAD;
  friendList,
  childAD: HWND;

implementation

{$R *.dfm}

//HKEY_CLASSES_ROOT\TypeLib\{B694121F-57B7-4F4D-9B07-0464BE376A1C}
function TfrmRemoveKakaoAD.getInstallDir: string;
var
  reg: TRegistry;
  res: String;
  pathIndex: integer;
begin
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CLASSES_ROOT;
  {
  카카오톡 기존  버전
  C:\Program Files (x86)\Kakao\KakaoTalk
  if reg.OpenKey('TypeLib\{B694121F-57B7-4F4D-9B07-0464BE376A1C\1.0\HELPDIR', false) then begin
  }

  //"D:\Program Files (x86)\Kakao\KakaoTalk\KakaoTalk.exe" "%1"
  if reg.OpenKey('kakaoopen\shell\open\command', false) then begin
    res := reg.ReadString('');
    reg.CloseKey;
  end;

  FreeAndNil(reg);

  //res := inttostr(Pos('KakaoTalk.exe', res));
  pathIndex := Pos('KakaoTalk.exe', res);
  if pathIndex > 0 then begin
    res := copy(res, 2, pathIndex - 3);
  end;

  Result := res;
end;

function EnumWindowsProc(Handle: HWND):Bool; stdcall;
var
  ClassName: string;
  Title: array[0..255] of Char;
  Rect: TRect;
  Flag: boolean;
begin
  if IsWindowVisible(Handle) and ((GetWindowLong(Handle, WS_EX_DLGMODALFRAME) = 0)) then begin
        SetLength (ClassName, 100);
        GetClassName (Handle, PChar (ClassName), Length (ClassName));
        ClassName := PChar (ClassName);
        GetWindowText(Handle, Title, 255);

        Flag := False;

        // 카카오톡 하단의 광고
        if ClassName = '#32770' then begin
          if (Title = '카카오톡') then Flag := True;
          if (Title = 'KakaoTalk') then Flag := True;
          if (Title = 'カカオト?ク') then Flag := True;
          if Flag then begin
              GetWindowRect(Handle, Rect);
              friendList :=  FindWindowEx(Handle, 0, '#32770', nil);
              childAD := FindWindowEx(Handle, 0, 'EVA_Window', nil);

              //GetWindowText(childAD, titleAD, 255);
              if (childAD > 0) then begin
                //showWindow(childAD, SW_HIDE);
                SetWindowPos(childAD, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE);
                SetWindowPos(friendList, HWND_BOTTOM, 0, 0, (Rect.Right - Rect.Left), (Rect.Bottom - Rect.Top - 36), SWP_NOMOVE);
                if frmRemoveKakaoAD.tmrClose.Enabled = False then begin

                  frmRemoveKakaoAD.setStateCompleted(frmRemoveKakaoAD.lblState1);
                  frmRemoveKakaoAD.setActiveControl(frmRemoveKakaoAD.lblResult2);
                  frmRemoveKakaoAd.lblResult2.Caption := '광고가 제거되었습니다.';
                  frmRemoveKakaoAD.tmrClose.Enabled := True;
                  //frmRemoveKakaoAD.lblResult2.Caption := '광고가 제거되었습니다.';
                end;
              end;
          end;
        end;

        // 랜덤으로 팝업되는 오른쪽 하단의 투명 광고
        if ClassName = 'EVA_Window' then begin
          SendMessage(Handle, WM_CLOSE, 0, 0);
        end;
    end;
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

procedure TfrmRemoveKakaoAD.tmrURLTimer(Sender: TObject);
begin
  CheckUrl;
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

procedure TfrmRemoveKakaoAD.lblReal21cClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'http://real21c.com/kakao-noadv', nil, nil, SW_SHOWNORMAL);
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
