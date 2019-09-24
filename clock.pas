{$reference 'System.Windows.Forms.dll'}
{$reference 'System.Drawing.dll'} 

uses System, System.Windows.Forms, System.Drawing, Timers;

type
  pos = record
    x: integer;
    y: integer;
  end;
  
  timeH = record
    hour, minute, second: integer;
  end;

var
  f: Form;
  PaintBox := new Panel();
  canvas := PaintBox.CreateGraphics;
  MenuC: MainMenu;
  itemMenu: array[0..2] of MenuItem;
  allSetting: Panel;
  settingTimerGroup: GroupBox;
  settingStopwatchGroup: GroupBox;
  changeNum: array[0..2] of NumericUpDown;
  labelChangeNum: array[0..2] of System.Windows.Forms.Label;
  buttonTimer: array[0..2] of Button;
  buttonStopwatch: array[0..2] of Button;
  outputStopwatch: System.Windows.Forms.Label;
  
  PaintBoxSize: integer := 500;
  cpadding: integer := 5;
  r := Round(PaintBoxSize / 2) - cpadding;
  rs: integer := 10;
  wp, hp: array[0..12] of integer;
  h: array[0..12] of string;
  posEnd: pos;
  time: DateTime;
  selectMode: string := 'Clock';
  counter: integer := 0;
  secondT: integer := 1;
  CountUpdate: integer;
  isStart: boolean := false;
  t: integer := 20;
  defaultTime: timeH; 
  
  family := new FontFamily('Consolas');
  emSize: single := 16;
  Pen := new Pen(Color.Black);
  Brush := new SolidBrush(Color.Black);
  Font := new Font(family, emSize);
  stringSize: SizeF;


///требуется для направления стрелки.
///возвращает координаты конца стрелки в типе pos.
///Параметр y0: координата начала линии на оси y.
///Параметр x0: координата начала линии на оси x.
///Параметр r: длинна линии.
///Параметр time: время в целочисленном формате.
///Параметр t: принимает 'o' для минут и секунд и 'h' для часов.
function arrowpos(y0, x0: integer; r: real; time: integer; t: char): pos;
var
  position: pos;
  k: real;
begin
  if t = 'o' then k := 360 / 12;
  if t = 'h' then k := 360 / 60;
  position.x := x0 + Round(r * sin(Pi * time / k));
  position.y := y0 - Round(r * cos(Pi * time / k));
  Result := position;
end;


procedure Update(t: integer); forward;

procedure StartT(sender: object; e: EventArgs); forward;

procedure PauseT(sender: object; e: EventArgs); forward;

procedure StopT(sender: object; e: EventArgs); forward;

procedure Dial(time: timeH); forward;


procedure ChangeClock(sender: object; e: EventArgs);
begin
  selectMode := 'Clock';
  settingStopwatchGroup.Enabled := false;
  settingTimerGroup.Enabled := false;
end;

procedure ChangeStopwatch(sender: object; e: EventArgs);
begin
  isStart := false;
  Dial(defaultTime);
  selectMode := 'Stopwatch';
  settingStopwatchGroup.Enabled := true;
  settingTimerGroup.Enabled := false;
end;

procedure ChangeTimer(sender: object; e: EventArgs);
begin
  Dial(defaultTime);
  selectMode := 'Timer';
  settingStopwatchGroup.Enabled := false;
  settingTimerGroup.Enabled := true;
end;


procedure StartS(sender: object; e: EventArgs);
begin
  secondT := 0;
  isStart := true;
end;

procedure PauseS(sender: object; e: EventArgs);
begin
  if isStart = true then isStart := False else isStart := true;
end;

procedure StopS(sender: object; e: EventArgs);
var
  t: timeH;
begin
  secondT -= 1;
  t.second := secondT mod 60;
  t.minute := (secondT div 60) mod 60;
  t.hour := ((secondT div 60) div 60) mod 24;
  outputStopwatch.Text := t.hour + 'h ' + t.minute + 'm ' + t.second + 's';
  isStart := false;
  MessageBox.Show(t.hour + 'h ' + t.minute + 'm ' + t.second + 's');
  secondT := 0;
end;


procedure Init;
var
  itemMenuTitle: array[0..2] of string := ('Clock', 'Timer', 'Stopwatch');
  ButtonTitle: array[0..2] of string := ('Start', 'Pause', 'Stop');
  controlTimer: array[0..2] of procedure(sender: object; e: EventArgs) := (StartT, PauseT, StopT);
  controlStopwatch: array[0..2] of procedure(sender: object; e: EventArgs) := (StartS, PauseS, StopS);
begin
  CountUpdate := 1000;
  defaultTime.hour := 0;
  defaultTime.minute := 0;
  defaultTime.second := 0;
  
  f := new Form;
  f.Text := 'Clock';
  f.ClientSize := new Size(PaintBoxSize, PaintBoxSize + 120);
  f.MinimumSize := new Size(PaintBoxSize, PaintBoxSize);
  f.FormBorderStyle := FormBorderStyle.FixedSingle;
  
  MenuC := new MainMenu();  
  for var i := 0 to 2 do
  begin
    itemMenu[i] := new MenuItem();
    itemMenu[i].Text := itemMenuTitle[i];
  end;
  
  itemMenu[0].Click += ChangeClock;
  itemMenu[1].Click += ChangeTimer;
  itemMenu[2].Click += ChangeStopwatch;
  
  for var i := 0 to 2 do
  begin
    MenuC.MenuItems.Add(itemMenu[i]);
  end;
  
  PaintBox.BackColor := Color.White;
  PaintBox.Size := new Size(PaintBoxSize, PaintBoxSize);
  PaintBox.Anchor := (AnchorStyles.top);
  
  allSetting := new Panel();
  allSetting.Anchor := (AnchorStyles.left or AnchorStyles.Right or AnchorStyles.Top);
  allSetting.Top := PaintBoxSize + 10;
  allSetting.BorderStyle := BorderStyle.Fixed3D;
  allSetting.Padding := new Padding(10);
  allSetting.Width := PaintBox.Width;
  
  settingTimerGroup := new GroupBox();
  settingTimerGroup.Text := 'Option for Timer';
  settingTimerGroup.Width := Round(allSetting.ClientSize.Width / 2);
  settingTimerGroup.Anchor := (AnchorStyles.left or AnchorStyles.Top);
  settingTimerGroup.BackColor := Color.White;
  settingTimerGroup.Enabled := false;
  
  settingStopwatchGroup := new GroupBox();
  settingStopwatchGroup.Text := 'Option for Stopwatch';
  settingStopwatchGroup.Left := Round(allSetting.ClientSize.Width / 2);
  settingStopwatchGroup.Width := Round(allSetting.ClientSize.Width / 2);
  settingStopwatchGroup.Anchor := (AnchorStyles.Right or AnchorStyles.Top);
  settingStopwatchGroup.BackColor := Color.White;
  settingStopwatchGroup.Enabled := false;
  
  //controlls for timer
  for var i := 0 to 2 do
  begin
    changeNum[i] := new NumericUpDown();
    changeNum[i].Top := 15 + 30 * i;
    changeNum[i].Width := 30 + 20;
    changeNum[i].Maximum := 59;
    changeNum[i].Minimum := 0;
    
    labelChangeNum[i] := new System.Windows.Forms.Label();
    labelChangeNum[i].Top := 15 + 30 * i;
    labelChangeNum[i].Left := changeNum[i].Width + 5;
    labelChangeNum[i].Width := 60;
    
    buttonTimer[i] := new Button();
    buttonTimer[i].Top := 15 + 30 * i;
    buttonTimer[i].Left := changeNum[i].Width + labelChangeNum[i].Width + 5;
    buttonTimer[i].Height := 20;
    buttonTimer[i].Text := ButtonTitle[i];
    buttonTimer[i].Click += controlTimer[i];
  end;
  changeNum[2].Maximum := 23;
  labelChangeNum[0].text := 'Second';
  labelChangeNum[1].text := 'Minute';
  labelChangeNum[2].text := 'Hour';
  
  
  //controls for stopwatch
  for var i := 0 to 2 do
  begin
    buttonStopwatch[i] := new Button();
    buttonStopwatch[i].Top := 15 + 30 * i;
    buttonStopwatch[i].Left := changeNum[i].Width + labelChangeNum[i].Width + 5;
    buttonStopwatch[i].Height := 20;
    buttonStopwatch[i].Text := ButtonTitle[i];
    buttonStopwatch[i].Click += controlStopwatch[i];
  end;
  outputStopwatch := new System.Windows.Forms.Label();
  outputStopwatch.Top := 15 + 30;
  outputStopwatch.Width := 60;
  
  
  f.Controls.Add(PaintBox);
  f.Menu := MenuC;
  f.Controls.Add(allSetting);
  allSetting.Controls.Add(settingTimerGroup);
  for var i := 0 to 2 do
  begin
    settingTimerGroup.Controls.Add(changeNum[i]);
    settingTimerGroup.Controls.Add(labelChangeNum[i]);
    settingTimerGroup.Controls.Add(buttonTimer[i]);
  end;
  allSetting.Controls.Add(settingStopwatchGroup);
  for var i := 0 to 2 do
  begin
    settingStopwatchGroup.Controls.Add(buttonStopwatch[i]);
  end;
  settingStopwatchGroup.Controls.Add(outputStopwatch);
  
  f.Load += (o, e)->
  begin
    canvas := PaintBox.CreateGraphics;
    
    for var i := 0 to 11 do
    begin
      h[i] := IntToStr(i + 1);
      stringSize := canvas.MeasureString(h[1], Font);
      
      wp[i] := Round(stringSize.Width / 2);
      hp[i] := Round(stringSize.Height / 2);
    end;
    
    Update(CountUpdate);
  end;
end;


procedure StartT(sender: object; e: EventArgs);
begin
  secondT := 0;
  
  for var i := 0 to 2 do
  begin
    if changeNum[i].Value <> 0 then
      secondT := secondT + Round(real(changeNum[i].Value) * Power(60, i));
  end;
  
  isStart := true;
end;

procedure PauseT(sender: object; e: EventArgs);
begin
  if isStart = true then isStart := False else isStart := true;
end;

procedure StopT(sender: object; e: EventArgs);
begin
  secondT := 0;
  isStart := false;
  MessageBox.Show('Время вышло');
  {for var i := 0 to 2 do
  changeNum[i].Value := 0;}
end;

procedure StopT;
begin
  secondT := 0;
  isStart := false;
  MessageBox.Show('Время вышло');
  for var i := 0 to 2 do
    changeNum[i].Value := 0;
end;


procedure Dial(time: TimeH);
var
  clear := new SolidBrush(Color.White);
begin
  Pen.Width := 1;
  //canvas.Clear(Color.White);
  canvas.FillEllipse(clear, (cpadding + r - (r - 30) * 2 / 2), (cpadding + r - (r - 30) * 2 / 2), (r - 30) * 2, (r - 30) * 2);
  
  canvas.DrawEllipse(Pen, (PaintBox.Size.Width / 2) - r, cpadding, r * 2, r * 2);
  canvas.DrawEllipse(Pen, (cpadding + r - rs / 2), (cpadding + r - rs / 2), rs, rs);  
  
  for var i := 0 to 11 do
  begin
    canvas.DrawString(h[i], Font, Brush, cpadding + (r + Round((r - 15) * sin(Pi * (i + 1) / (180 / 30))) - wp[i]), cpadding + (r - Round((r - 15) * cos(Pi * (i + 1) / (180 / 30))) - hp[i]));
  end;
  
  Pen.width := 2;
  posEnd := arrowpos(cpadding + r, cpadding + r, r - 30, time.second, 'o');
  canvas.DrawLine(Pen, cpadding + r, cpadding + r, posEnd.x, posEnd.y);
  Pen.width := 4;
  posEnd := arrowpos(cpadding + r, cpadding + r, r - 35, time.minute, 'o');
  canvas.DrawLine(Pen, cpadding + r, cpadding + r, posEnd.x, posEnd.y);
  Pen.width := 8;
  posEnd := arrowpos(cpadding + r, cpadding + r, r / 2, time.hour, 'h');
  canvas.DrawLine(Pen, cpadding + r, cpadding + r, posEnd.x, posEnd.y);
end;

procedure AClock;
var
  t: timeH;
begin
  f.Text := 'Clock (Clock mode)';
  t.hour := DateTime.Now.Hour;
  t.minute := DateTime.Now.Minute;
  t.second := DateTime.Now.Second;  
  Dial(t);
end;

procedure ATimer;
var
  t: timeH;
begin
  f.Text := 'Clock (Timer mode)';
  if isStart = true then
  begin
    counter += CountUpdate;
    t.second := secondT mod 60;
    t.minute := (secondT div 60) mod 60;
    t.hour := ((secondT div 60) div 60) mod 24;
    if counter >= 1000 then 
    begin
      secondT -= 1;
      counter := 0;
    end;
    Dial(t);
    if secondT <= -1 then StopT;
  end;
end;

procedure AStopwatch;
var
  t: timeH;
begin
  f.Text := 'Clock (Stopwatch mode)';
  if isStart = true then
  begin
    counter += CountUpdate;
    t.second := secondT mod 60;
    t.minute := (secondT div 60) mod 60;
    t.hour := ((secondT div 60) div 60) mod 24;
    if counter >= 1000 then 
    begin
      secondT += 1;
      counter := 0;
    end;
    Dial(t);
  end;  
end;

procedure Draw;
begin
  case selectMode of
    'Clock': AClock;
    'Timer': ATimer;
    'Stopwatch': AStopwatch;
  end;
end;

procedure Update(t: integer);
begin
  var mainLoop := new Timer(t, Draw);
  mainLoop.Start;
end;

begin
  Init;
  Application.Run(f);
end.