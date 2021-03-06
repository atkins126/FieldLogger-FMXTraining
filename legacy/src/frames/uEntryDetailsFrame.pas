unit uEntryDetailsFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Sensors,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Ani, FMX.Objects, FMX.Layouts, FMX.Effects,
  FMX.Filter.Effects, FMX.Platform, System.Permissions, FMX.Edit, fieldlogger.data
{$IFDEF ANDROID}
  , Androidapi.JNI.Os, Androidapi.JNI.JavaTypes, Androidapi.Helpers
{$ENDIF ANDROID}
  ;

type
  TEntryDetailsFrame = class(TFrame)
    Image5: TImage;
    imgPicture: TImage;
    LongitudeRectangle: TRectangle;
    Label7: TLabel;
    lblLongitude: TLabel;
    LatitudeRectangle: TRectangle;
    Label9: TLabel;
    lblLatitude: TLabel;
    ALIRectangle: TRectangle;
    Label11: TLabel;
    SubThoroughfareRectangle: TRectangle;
    Label12: TLabel;
    lblSubThoroughfare: TLabel;
    ThoroughfareRectangle: TRectangle;
    Label14: TLabel;
    lblThoroughfare: TLabel;
    SubLocalityRectangle: TRectangle;
    Label16: TLabel;
    lblSubLocality: TLabel;
    SubAdminRectangle: TRectangle;
    Label18: TLabel;
    lblSubAdminArea: TLabel;
    ZipRectangle: TRectangle;
    Label20: TLabel;
    lblZipCode: TLabel;
    LocalityRectangle: TRectangle;
    Label22: TLabel;
    lblLocality: TLabel;
    FeatureRectangle: TRectangle;
    Label24: TLabel;
    lblFeature: TLabel;
    CountryRectangle: TRectangle;
    Label26: TLabel;
    lblCountry: TLabel;
    CountryCodeRectangle: TRectangle;
    Label28: TLabel;
    lblCountryCode: TLabel;
    AdminAreaRectangle: TRectangle;
    Label30: TLabel;
    lblAdminArea: TLabel;
    ToolBar3: TToolBar;
    ToolBarBackgroundRect: TRectangle;
    Label6: TLabel;
    btnEntriesBack: TButton;
    btnDeleteEntry: TSpeedButton;
    VertScrollBox1: TVertScrollBox;
    InfoLayout: TLayout;
    ImageTitleRect: TRectangle;
    Label1: TLabel;
    Layout1: TLayout;
    Layout2: TLayout;
    Circle1: TCircle;
    LogoImage: TImage;
    Layout3: TLayout;
    AddLogEntryCircleBTN: TCircle;
    AddButton: TSpeedButton;
    ShadowEffect1: TShadowEffect;
    MapImage: TImage;
    BackgroundRect: TRectangle;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Label4: TLabel;
    Label2: TLabel;
    NoteEdit: TEdit;
    procedure btnDeleteEntryClick(Sender: TObject);
    procedure btnEntriesBackClick(Sender: TObject);
    procedure AddLogEntryCircleBTNClick(Sender: TObject);
    procedure AddLogEntryCircleBTNMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  private
    { Private declarations }
    procedure SetNote(const ANote: String);
  public
    { Public declarations }
    procedure UpdateDetails(const Address: TCivicAddress);
    procedure LoadEntryDetail(LogID: Integer; AProject: TProject);
    procedure DownloadStaticMap(const aLocation:String; aHeight, aWidth: Single; aImage: TImage);
  end;

implementation

{$R *.fmx}

uses
  formMain, uDataModule;

procedure TEntryDetailsFrame.SetNote(const ANote: String);
begin
  NoteEdit.Text := ANote;
end;

procedure TEntryDetailsFrame.LoadEntryDetail(LogID: Integer; AProject: TProject);
var
  LogData: ILogData;
  LogEntries: TArrayOfLogEntry;
  Found: integer;
  idx: integer;
  Bitmap: TBitmap;
begin
  // - Init the tab
  imgPicture.Bitmap.Clear(TAlphaColorRec.Null);
  lblLongitude.Text := '???';
  lblLatitude.Text := '???';
  lblSubThoroughfare.Text := '???';
  lblThoroughfare.Text := '???';
  lblSubLocality.Text := '???';
  lblSubAdminArea.Text := '???';
  lblZipCode.Text := '???';
  lblLocality.Text := '???';
  lblFeature.Text := '???';
  lblCountry.Text := '???';
  lblCountryCode.Text := '???';
  lblAdminArea.Text := '???';
  // - Get data
  LogData := TLogData.Create(mainDM.conn);
  if not assigned(LogData) then
  begin
    raise EConnectFailed.Create;
  end;
  LogData.Read(LogEntries, AProject.ID);
  if Length(LogEntries) = 0 then
  begin
    exit;
  end;
  // - Loop through and find the log entry we want
  frmMain.CurrentLogEntry := 0;
  Found := 0;
  for idx := 0 to pred(Length(LogEntries)) do
  begin
    if LogEntries[idx].ID = LogID then
    begin
      frmMain.CurrentLogEntry := LogEntries[idx].ID;
      Found := idx;
      break;
    end;
  end;
  if frmMain.CurrentLogEntry = 0 then
  begin
    exit;
  end;
  // - Load the entry to the form.
  Bitmap := LogEntries[Found].getPicture;
  try
    imgPicture.Bitmap.SetSize(Bitmap.Width,Bitmap.Height);
    imgPicture.Bitmap.CopyFromBitmap(Bitmap);
    //imgPicture.Bitmap.Assign(Bitmap);
  finally
    Bitmap.DisposeOf;
  end;
  lblLongitude.Text := LogEntries[Found].Longitude.ToString;
  lblLatitude.Text := LogEntries[Found].Latitude.ToString;

  SetNote(LogEntries[Found].Note);

  try
    frmMain.ReverseLocation(LogEntries[Found].Latitude, LogEntries[Found].Longitude);
  except
  end;

  DownloadStaticMap(lblLatitude.Text + ',' + lblLongitude.Text, MapImage.Height, MapImage.Width, MapImage);
end;


procedure TEntryDetailsFrame.UpdateDetails(const Address: TCivicAddress);
begin
  lblSubThoroughfare.Text := Address.SubThoroughfare;
  lblThoroughfare.Text := Address.Thoroughfare;
  lblSubLocality.Text := Address.SubLocality;
  lblSubAdminArea.Text := Address.SubAdminArea;
  lblZipCode.Text := Address.PostalCode;
  lblLocality.Text := Address.Locality;
  lblFeature.Text := Address.FeatureName;
  lblCountry.Text := Address.CountryName;
  lblCountryCode.Text := Address.CountryCode;
  lblAdminArea.Text := Address.AdminArea;
end;

procedure TEntryDetailsFrame.DownloadStaticMap(const aLocation: String; aHeight, aWidth: Single; aImage: TImage);
begin
  frmMain.DownloadStaticMap(aLocation, aHeight, aWidth, aImage);
end;


procedure TEntryDetailsFrame.AddLogEntryCircleBTNClick(Sender: TObject);
begin
  frmMain.NewProjectEntry;
end;

procedure TEntryDetailsFrame.AddLogEntryCircleBTNMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  frmMain.MaterialDesignMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TEntryDetailsFrame.btnDeleteEntryClick(Sender: TObject);
var
  ASyncService: IFMXDialogServiceASync;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXDialogServiceAsync, IInterface(ASyncService)) then
  begin
    ASyncService.MessageDialogAsync( 'Delete this Log Entry?', TMsgDlgType.mtConfirmation,
                                                   [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0,
     procedure(const AResult: TModalResult)
     begin
       case AResult of
         mrYES: begin

              frmMain.DeleteLogEntry;

            end;
       end;
     end);
  end;
end;

procedure TEntryDetailsFrame.btnEntriesBackClick(Sender: TObject);
begin
  frmMain.SetBackToProjectDetailScreen;
end;

end.
