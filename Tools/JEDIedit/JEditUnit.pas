{==============================================================================}
{   JEDIedit command line text file editing program, file "JEditUnit.pas"      }
{                                                                              }
{   Copyright (C) 2010 Conrad T. Pino.  All rights reserved.                   }
{------------------------------------------------------------------------------}
{   The contents of this file are subject to the Mozilla Public License        }
{   Version 1.1 (the "License"); you may not use this file except in           }
{   compliance with the License. You may obtain a copy of the License          }
{   at http://www.mozilla.org/MPL/                                             }
{                                                                              }
{   Software distributed under the License is distributed on an "AS IS"        }
{   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See        }
{   the License for the specific language governing rights and limitations     }
{   under the License.                                                         }
{                                                                              }
{   The Original Code is "JEditUnit.pas".                                      }
{                                                                              }
{   The Initial Developer of the Original Code is Conrad T. Pino.              }
{                                                                              }
{   Contributor(s): (none).                                                    }
{                                                                              }
{   Alternatively, the contents of this file may be used under the terms of    }
{   the GPL license (the "GNU General Public License"), in which case the      }
{   provisions of the GPL are applicable instead of those above. If you wish   }
{   to allow use of your version of this file only under the terms of the GPL  }
{   and not to allow others to use your version of this file under the MPL,    }
{   indicate your decision by deleting the provisions above and replace them   }
{   with the notice and other provisions required by the GPL. If you do not    }
{   delete the provisions above, a recipient may use your version of this      }
{   file under either the MPL or the GPL.                                      }
{------------------------------------------------------------------------------}
{   This program is free software: you can redistribute it and/or modify it    }
{   under the terms of the GNU General Public License as published by the      }
{   Free Software Foundation, either version 3 of the License, or (at your     }
{   option) any later version.                                                 }
{                                                                              }
{   This program is distributed in the hope that it will be useful, but        }
{   WITHOUT ANY WARRANTY; without even the implied warranty of                 }
{   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU          }
{   General Public License for more details.                                   }
{                                                                              }
{   You should have received a copy of the GNU General Public License along    }
{   with this program.  If not, see <http://www.gnu.org/licenses/>.            }
{                                                                              }
{   Alternatively, the contents of this file may be used under the terms of    }
{   the MPL license (the "Mozilla Public License"), in which case the          }
{   provisions of the MPL are applicable instead of those above. If you wish   }
{   to allow use of your version of this file only under the terms of the MPL  }
{   and not to allow others to use your version of this file under the GPL,    }
{   indicate your decision by deleting the provisions above and replace them   }
{   with the notice and other provisions required by the MPL. If you do not    }
{   delete the provisions above, a recipient may use your version of this      }
{   file under either the GPL or the MPL.                                      }
{==============================================================================}
unit JEditUnit;

{==============================================================================}

interface

{==============================================================================}

function RunProgram: Integer;

{==============================================================================}

implementation

uses
  Classes, IniFiles, SysUtils;

{==============================================================================}

const
  CharSpace = ' ';
  CharTab = #9;

  FileJEDITeditIni = 'JEDIedit.ini';

  IniSectionDefault = 'Default';

  IniKeyRootPathList = 'RootPaths';
  IniKeyExcludesList = 'Excludes';
  IniKeyIncludesList = 'Includes';
  IniKeyExtensonList = 'Extensions';
  IniKeySkipDirsList = 'SkipDirs';
  IniKeyTabReplace = 'TabReplace';
  IniKeyTabReports = 'TabReports';
  IniKeyTabSpacing = 'TabSpacing';

  IniKeyRootPathListDefault = '"..\jedi-apilib","..\..\..\..\..\jedi-apilib"';
  IniKeyExcludesListDefault = '"jwapi\trunk\Examples","jwscl\trunk\examples","jwscl\trunk\unittests"';
  IniKeyIncludesListDefault = '"jwapi\trunk","jwscl\trunk"';
  IniKeyExtensonListDefault = '"dpr","inc","pas"';
  IniKeySkipDirsDefault = '"CVS",".svn"';
  IniKeyTabReplaceDefault = True;
  IniKeyTabReportsDefault = not IniKeyTabReplaceDefault;
  IniKeyTabSpacingDefault = 2;

  MessageInit = 'Greetings Earthling! Take me to your Leader.';
  MessageFile = 'File not found: %s.';
  MessageFini = 'Files: count %d, trim %d, tabs %d %d.';

type
  MessageHelpRange = 0..60;
const
  MessageHelp: array [ MessageHelpRange ] of string =
    (
      '',
      'JEDIedit (option|file|directory)*',
      '',
      '   --backup-file           Enables file backups, for example:',
      '   -b                      file Unit.pas becomes Unit.~pas and',
      '   /b                      modfied file content becomes Unit.pas.',
      '',
      '   --directories           Enables fully recursive directory search.',
      '   -d',
      '   /d',
      '',
      '   --extensions exts       File extensions to select where "exts" can be:',
      '   -e exts                     pas',
      '   /e exts                     dpr,inc,pas',
      '                               "pas"',
      '                               "dpr,inc,pas"',
      '',
      '   --ini-file filename     Reads INI filename instead of JEDIedit.ini and',
      '   -i filename             may be used alone or combined with --ini-section.',
      '   /i filename',
      '',
      '   --ini-section thisone   Reads INI section thisone instead of Default and',
      '   -j thisone              may be used alone or combined with --ini-file.',
      '   /j thisone',
      '',
      '   --root-paths pathlist   Replace INI file RootPaths value where pathlist is',
      '   -r pathlist             comma seperated possibly enclosed in double quotes',
      '   /r pathlist             and one path is sufficient.  This value is ignored',
      '                           when file or directories appear on command line.',
      '',
      '   --tab-replace           Enables Tab Replacement feature.',
      '   -t+',
      '   /t+',
      '   -t',
      '   /t',
      '',
      '   --no-tab-replace        Disables Tab Replacement feature.',
      '   -t-',
      '   /t-',
      '',
      '   --tab-report            Enables Tab Reporting feature.',
      '   -u+',
      '   /u+',
      '   -u',
      '   /u',
      '',
      '   --no-tab-report         Disables Tab Reporting feature.',
      '   -t-',
      '   /t-',
      '',
      '   --tab-spacing number    Tab Replacement feature spaces tabbed text number',
      '   -v number               columns apart.',
      '   /v number',
      '',
      '   --yes-prompt            Prompt for yes confirmation prior to saving changed',
      '   -y                      files; pressing Enter key alone or any text begining',
      '   /y                      with letter Y or y followed by Enter key saves changes.',
      '',
      '   --help                  Display this help message.',
      '   -?',
      '   /?'
    );

{==============================================================================}

function RightTrim( var Trimmed: Boolean; const Arg: string ): string;

  var
    Index, Limit: Integer;

begin
  Result := Arg;

  Index := Length( Arg );
  Limit := Index;
  while ( Index > 0 ) and ( Result[ Index ] <= ' ' ) do Dec( Index );

  Trimmed := Index < Limit;
  if Trimmed then SetLength( Result, Index );
end;

{==============================================================================}

function ReplaceTabs( var Replaced: Boolean;
                      const Arg: string;
                      const TabSpacing: Integer
                      ): string;

  var
    Index: Integer;
    Source: string;

begin
  Replaced := False;
  Result := '';
  Source := Arg;

  Index := Pos( CharTab, Source );
  while Index > 0 do
  begin
    Result := Result + Copy( Source, 1, Index - 1 );
    Delete( Source, 1, Index );

    Result := Result
            +  StringOfChar(  CharSpace,
                              TabSpacing - Length( Result ) mod TabSpacing
                              )
            ;

    Replaced := True;

    Index := Pos( CharTab, Source );
  end;

  Result := Result + Source;
end;

{==============================================================================}

type
  TFileEdit = class( TStringList )
  public
    function EditTabs(  const FileName: string;
                        const TabSpacing: Integer
                        ): Boolean;
    function EditWhiteSpace( const FileName: string ): Boolean;
    function FindTabs( const FileName: string ): string;

  end;

{------------------------------------------------------------------------------}

type
  TFileList = class( TStringList )
  public
    BackupOption: Boolean;

    procedure AddFiles( const Path: string;
                        const Recursive: Boolean;
                        const SkipDirsList: TStringList
                        );

    function Backup( const Index: Integer ): Boolean;
  end;

  TFileRecord = class( TObject )
    EditCount: Integer;
  end;

{------------------------------------------------------------------------------}

type
  TProgramOptionId =
    (
      optBackupFile,
      optDirectories,
      optExtensions,
      optExtensionsError,
      optIniFileName,
      optIniFileNameError,
      optIniFileSection,
      optIniFileSectionError,
      optMessageHelp,
      optRootPaths,
      optRootPathsError,
      optTabReplace,
      optTabReports,
      optTabSpacing,
      optTabSpacingError,
      optYesPrompt
    );

  TProgramOptionUsed = set of TProgramOptionId;

  TProgramOptions = record
    BackupFile,
    Recursive,
    TabReplace,
    TabReports,
    YesPrompt: Boolean;

    TabSpacing: Integer;

    RootPaths,
    Extensions,
    IniFileName,
    IniSectionName: string;

    FilesPaths: array of string;

    OptionUsed: TProgramOptionUsed;
  end;

{==============================================================================}

function TFileEdit.EditTabs(  const FileName: string;
                              const TabSpacing: Integer
                              ): Boolean;

  var
    Index: Integer;
    Replaced: Boolean;

begin
  Result := False;
  try
    LoadFromFile( FileName );

    // Edit all lines containing tabs
    Index := 0;
    while Index < Count do
    begin
      Strings[ Index ] := ReplaceTabs( Replaced, Strings[ Index ], TabSpacing );
      Result := Result or Replaced;
      Inc( Index );
    end;

  except
  end;
end;

{------------------------------------------------------------------------------}

function TFileEdit.EditWhiteSpace( const FileName: string ): Boolean;

  var
    Index: Integer;
    Trimmed: Boolean;

begin
  Result := False;
  try
    LoadFromFile( FileName );

    // Right Trim all lines
    Index := 0;
    while Index < Count do
    begin
      Strings[ Index ] := RightTrim( Trimmed, Strings[ Index ] );
      Result := Result or Trimmed;
      Inc( Index );
    end;

    // Discard leading blank lines
    Index := 0;
    while ( Index < Count ) and ( Length( Strings[ Index ] ) = 0 ) do
    begin
      Delete( Index );
      Result := True;
      // Delete( Index ) decrements Count; omit Inc( Index );
    end;

    // Discard trailing blank lines
    Index := Count - 1;
    while ( Index >= 0 ) and ( Length( Strings[ Index ] ) = 0 ) do
    begin
      Delete( Index );
      Result := True;
      Dec( Index );
    end;

  except
  end;
end;

{------------------------------------------------------------------------------}

function TFileEdit.FindTabs( const FileName: string ): string;

  var
    Index: Integer;

begin
  Result := '';
  try
    try
      LoadFromFile( FileName );

      // Find all lines containing a tab
      Index := 0;
      while Index < Count do
      begin
        if Pos( CharTab, Strings[ Index ] ) > 0 then
        begin
          Result := Result + IntToStr( Index + 1 ) + ',';
        end;

        Inc( Index );
      end;

      // Discard trailing comma (if any)
      Index := Length( Result );
      if Index > 0 then
      begin
        SetLength( Result, Index - 1 );
      end;

    except
    end;
  finally
    Clear;
  end;
end;

{==============================================================================}
{
type
  TSearchRec = record
    Time: Integer;
    Size: Integer;
    Attr: Integer;
    Name: TFileName;
    ExcludeAttr: Integer;
    FindHandle: THandle;
    FindData: TWin32FindData;
  end;
}

{$WARN SYMBOL_PLATFORM OFF}

procedure TFileList.AddFiles( const Path: string;
                              const Recursive: Boolean;
                              const SkipDirsList: TStringList
                              );

  const
    PathSep = '\';
    AnyFile = PathSep + '*.*';

  var
    SearchRec: TSearchRec;

begin
  if FindFirst( Path + AnyFile, faAnyFile, SearchRec ) = 0 then
  begin
    repeat
      if ( ( SearchRec.Attr and faDirectory ) <> 0 ) and Recursive then
      begin
        if ( SkipDirsList.IndexOf( SearchRec.Name ) < 0 ) then
        begin
          AddFiles( Path + PathSep + SearchRec.Name, Recursive, SkipDirsList );
        end;
      end
      else
      if ( SearchRec.Attr and faVolumeID ) <> 0 then
      begin
        // Ignore Volume Labels
      end
      else
      begin
        Add( Path + PathSep + SearchRec.Name );
      end;

    until FindNext( SearchRec ) <> 0;

    FindClose( SearchRec );
  end;
end;

{$WARN SYMBOL_PLATFORM ON}

{------------------------------------------------------------------------------}

function TFileList.Backup( const Index: Integer ): Boolean;

  var
    FileBack, FileExtn, FileName: string;

begin
  Result := True;
  with Objects[ Index ] as TFileRecord do
  begin
    EditCount := EditCount + 1;

    if not BackupOption or ( EditCount > 1 ) then Exit;
  end;

  FileName := Strings[ Index ];
  FileExtn := '.~' + Copy( ExtractFileExt( FileName ), 2, MaxInt );
  FileBack := ChangeFileExt( FileName, FileExtn );

  if FileExists( FileBack ) then
  begin
    Result := DeleteFile( FileBack ) and RenameFile( FileName, FileBack );
  end
  else
  begin
    Result := RenameFile( FileName, FileBack );
  end;
end;

{==============================================================================}

function RunProgram: Integer;

  {----------------------------------------------------------------------------}

  var // 1 of 2 (see below)
    Option: TProgramOptions;

  {----------------------------------------------------------------------------}

  procedure InitializeStringList( StringList: TStringList );
  begin
    StringList.Duplicates := dupIgnore;
    StringList.CaseSensitive := False;
    StringList.Sorted := True;
  end;

  {----------------------------------------------------------------------------}

  function SaveChangeYes: Boolean;
    var
      InputText: string;
  begin
    if Option.YesPrompt then
    begin
      Write( ' changed, save? [y] ' );
      ReadLn( InputText );
      Result := ( Length( InputText ) = 0 ) or ( CompareText( InputText[ 1 ], 'y' ) = 0 );
    end
    else
    begin
      Result := True;
    end;
  end;

  {----------------------------------------------------------------------------}

  procedure ShowMessageHelp;
    var
      Index: Integer;
  begin
    for Index := Low( MessageHelpRange ) to High( MessageHelpRange ) do
    begin
      WriteLn( MessageHelp[ Index ] );
    end;
  end;

  {----------------------------------------------------------------------------}

  procedure ShowOptionError( const OptionId: TProgramOptionId );
  begin
    WriteLn;
    Write( 'Bad ' );

    case OptionId of
    optExtensionsError:
      Write( '--extensions' );

    optIniFileNameError:
      Write( '--ini-file' );

    optIniFileSectionError:
      Write( '--ini-section' );

    optRootPathsError:
      Write( '--root-paths' );

    optTabSpacingError:
      Write( '--tab-spacing' );

    end;

    WriteLn( ' option.' );
  end;

  {----------------------------------------------------------------------------}

  var // 2 of 2 (see above)
    FileEdit: TFileEdit;
    FileList: TFileList;
    RootPathList,
    ExcludesList,
    IncludesList,
    ExtensonList,
    SkipDirsList: TStringList;
    Argument, FileExtn, FileName, RootPath, TabLines: string;
    Compare, EditedTabs, EditedTrim, FinderTabs, Index, Jadex: Integer;
    IniFile: TMemIniFile;
    BadFilePath, SaveIniFile: Boolean;

  {----------------------------------------------------------------------------}

begin
  Result := 0;

  WriteLn( MessageInit );

  {----------------------------------------------------------------------------}

  Option.BackupFile := False;
  Option.Recursive := False;
  Option.YesPrompt := False;
  Option.TabReplace := IniKeyTabReplaceDefault;
  Option.TabReports := IniKeyTabReportsDefault;
  Option.TabSpacing := IniKeyTabSpacingDefault;
  Option.RootPaths := IniKeyRootPathListDefault;
  Option.Extensions := IniKeyExtensonListDefault;
  Option.IniFileName := FileJEDITeditIni;
  Option.IniSectionName := IniSectionDefault;

  // Command line arguments
  BadFilePath := False;
  Index := 1; Jadex := 0;
  while Index <= ParamCount do
  begin
    Argument := ParamStr( Index );
    Inc( Index );

    if ( CompareText( Argument, '--backup-file' ) = 0 )
    or ( CompareText( Argument, '-b' ) = 0 )
    or ( CompareText( Argument, '/b' ) = 0 ) then
    begin
      Option.OptionUsed := Option.OptionUsed + [ optBackupFile ];
      Option.BackupFile := True;
    end
    else
    if ( CompareText( Argument, '--directories' ) = 0 )
    or ( CompareText( Argument, '-d' ) = 0 )
    or ( CompareText( Argument, '/d' ) = 0 ) then
    begin
      Option.OptionUsed := Option.OptionUsed + [ optDirectories ];
      Option.Recursive := True;
    end
    else
    if ( CompareText( Argument, '--extensions' ) = 0 )
    or ( CompareText( Argument, '-e' ) = 0 )
    or ( CompareText( Argument, '/e' ) = 0 ) then
    begin
      if Index <= ParamCount then
      begin
        Option.OptionUsed := Option.OptionUsed + [ optExtensions ];
        Option.Extensions := ParamStr( Index );
        Inc( Index );
      end
      else
      begin
        Option.OptionUsed := Option.OptionUsed + [ optExtensionsError ];
      end;
    end
    else
    if ( CompareText( Argument, '--help' ) = 0 )
    or ( CompareText( Argument, '-?' ) = 0 )
    or ( CompareText( Argument, '/?' ) = 0 ) then
    begin
      Option.OptionUsed := Option.OptionUsed + [ optMessageHelp ];
    end
    else
    if ( CompareText( Argument, '--ini-file' ) = 0 )
    or ( CompareText( Argument, '-i' ) = 0 )
    or ( CompareText( Argument, '/i' ) = 0 ) then
    begin
      if Index <= ParamCount then
      begin
        Option.OptionUsed := Option.OptionUsed + [ optIniFileName ];
        Option.IniFileName := ParamStr( Index );
        Inc( Index );
      end
      else
      begin
        Option.OptionUsed := Option.OptionUsed + [ optIniFileNameError ];
      end;
    end
    else
    if ( CompareText( Argument, '--ini-section' ) = 0 )
    or ( CompareText( Argument, '-j' ) = 0 )
    or ( CompareText( Argument, '/j' ) = 0 ) then
    begin
      if Index <= ParamCount then
      begin
        Option.OptionUsed := Option.OptionUsed + [ optIniFileSection ];
        Option.IniSectionName := ParamStr( Index );
        Inc( Index );
      end
      else
      begin
        Option.OptionUsed := Option.OptionUsed + [ optIniFileSectionError ];
      end;
    end
    else
    if ( CompareText( Argument, '--root-paths' ) = 0 )
    or ( CompareText( Argument, '-r' ) = 0 )
    or ( CompareText( Argument, '/r' ) = 0 ) then
    begin
      if Index <= ParamCount then
      begin
        Option.OptionUsed := Option.OptionUsed + [ optRootPaths ];
        Option.RootPaths := ParamStr( Index );
        Inc( Index );
      end
      else
      begin
        Option.OptionUsed := Option.OptionUsed + [ optRootPathsError ];
      end;
    end
    else
    if ( CompareText( Argument, '--tab-replace' ) = 0 )
    or ( CompareText( Argument, '-t+' ) = 0 )
    or ( CompareText( Argument, '/t+' ) = 0 )
    or ( CompareText( Argument, '-t' ) = 0 )
    or ( CompareText( Argument, '/t' ) = 0 ) then
    begin
      Option.OptionUsed := Option.OptionUsed + [ optTabReplace ];
      Option.TabReplace := True;
    end
    else
    if ( CompareText( Argument, '--no-tab-replace' ) = 0 )
    or ( CompareText( Argument, '-t-' ) = 0 )
    or ( CompareText( Argument, '/t-' ) = 0 ) then
    begin
      Option.OptionUsed := Option.OptionUsed + [ optTabReplace ];
      Option.TabReplace := False;
    end
    else
    if ( CompareText( Argument, '--tab-report' ) = 0 )
    or ( CompareText( Argument, '-u+' ) = 0 )
    or ( CompareText( Argument, '/u+' ) = 0 )
    or ( CompareText( Argument, '-u' ) = 0 )
    or ( CompareText( Argument, '/u' ) = 0 ) then
    begin
      Option.OptionUsed := Option.OptionUsed + [ optTabReports ];
      Option.TabReports := True;
    end
    else
    if ( CompareText( Argument, '--no-tab-report' ) = 0 )
    or ( CompareText( Argument, '-u-' ) = 0 )
    or ( CompareText( Argument, '/u-' ) = 0 ) then
    begin
      Option.OptionUsed := Option.OptionUsed + [ optTabReports ];
      Option.TabReports := False;
    end
    else
    if ( CompareText( Argument, '--tab-spacing' ) = 0 )
    or ( CompareText( Argument, '-v' ) = 0 )
    or ( CompareText( Argument, '/v' ) = 0 ) then
    begin
      if Index <= ParamCount then
      begin
        Option.TabSpacing := StrToIntDef( ParamStr( Index ), 0 );
        Inc( Index );
        if Option.TabSpacing > 0 then
        begin
          Option.OptionUsed := Option.OptionUsed + [ optTabSpacing ];
        end
        else
        begin
          Option.OptionUsed := Option.OptionUsed + [ optTabSpacingError ];
        end;
      end
      else
      begin
        Option.OptionUsed := Option.OptionUsed + [ optTabSpacingError ];
      end;
    end
    else
    if ( CompareText( Argument, '--yes-prompt' ) = 0 )
    or ( CompareText( Argument, '-y' ) = 0 )
    or ( CompareText( Argument, '/y' ) = 0 ) then
    begin
      Option.OptionUsed := Option.OptionUsed + [ optYesPrompt ];
      Option.YesPrompt := True;
    end
    else
    if DirectoryExists( Argument ) or FileExists( Argument ) then
    begin
      SetLength( Option.FilesPaths, Jadex + 1 );
      Option.FilesPaths[ Jadex ] := Argument;
      Inc( Jadex );
    end
    else
    begin
      Option.OptionUsed := Option.OptionUsed + [ optMessageHelp ];
      WriteLn;
      Write( Format( MessageFile, [ Argument ] ) );
      BadFilePath := True;
    end;
  end;
  if BadFilePath then WriteLn;
  if optExtensionsError     in Option.OptionUsed then ShowOptionError( optExtensionsError );
  if optIniFileNameError    in Option.OptionUsed then ShowOptionError( optIniFileNameError );
  if optIniFileSectionError in Option.OptionUsed then ShowOptionError( optIniFileSectionError );
  if optRootPathsError      in Option.OptionUsed then ShowOptionError( optRootPathsError );
  if optTabSpacingError     in Option.OptionUsed then ShowOptionError( optTabSpacingError );
  if  [ optExtensionsError,
        optIniFileNameError,
        optIniFileSectionError,
        optRootPathsError,
        optTabSpacingError,
        optMessageHelp
      ] * Option.OptionUsed <> [ ] then
  begin
    ShowMessageHelp;
    Exit;
  end;

  {----------------------------------------------------------------------------}

  FileEdit := TFileEdit.Create;
  FileList := TFileList.Create;
  RootPathList := TStringList.Create;
  ExcludesList := TStringList.Create;
  IncludesList := TStringList.Create;
  ExtensonList := TStringList.Create;
  SkipDirsList := TStringList.Create;
  IniFile := TMemIniFile.Create( Option.IniFileName );

  {----------------------------------------------------------------------------}

  try
    {--------------------------------------------------------------------------}

    // Prepare IniFile
    SaveIniFile := False;
    if not IniFile.ValueExists( Option.IniSectionName, IniKeyRootPathList ) then
    begin
      IniFile.WriteString(  Option.IniSectionName,
                            IniKeyRootPathList,
                            Option.RootPaths
                            );
      SaveIniFile := True;
    end;
    if not IniFile.ValueExists( Option.IniSectionName, IniKeyExtensonList ) then
    begin
      IniFile.WriteString(  Option.IniSectionName,
                            IniKeyExtensonList,
                            Option.Extensions
                            );
      SaveIniFile := True;
    end;
    if not IniFile.ValueExists( Option.IniSectionName, IniKeyIncludesList ) then
    begin
      IniFile.WriteString(  Option.IniSectionName,
                            IniKeyIncludesList,
                            IniKeyIncludesListDefault
                            );
      SaveIniFile := True;
    end;
    if not IniFile.ValueExists( Option.IniSectionName, IniKeyExcludesList ) then
    begin
      IniFile.WriteString(  Option.IniSectionName,
                            IniKeyExcludesList,
                            IniKeyExcludesListDefault
                            );
      SaveIniFile := True;
    end;
    if not IniFile.ValueExists( Option.IniSectionName, IniKeySkipDirsList ) then
    begin
      IniFile.WriteString(  Option.IniSectionName,
                            IniKeySkipDirsList,
                            IniKeySkipDirsDefault
                            );
      SaveIniFile := True;
    end;
    if not IniFile.ValueExists( Option.IniSectionName, IniKeyTabReplace ) then
    begin
      IniFile.WriteBool(  Option.IniSectionName,
                          IniKeyTabReplace,
                          Option.TabReplace
                          );
      SaveIniFile := True;
    end;
    if not IniFile.ValueExists( Option.IniSectionName, IniKeyTabReports ) then
    begin
      IniFile.WriteBool(  Option.IniSectionName,
                          IniKeyTabReports,
                          Option.TabReports
                          );
      SaveIniFile := True;
    end;
    if not IniFile.ValueExists( Option.IniSectionName, IniKeyTabSpacing ) then
    begin
      IniFile.WriteInteger( Option.IniSectionName,
                            IniKeyTabSpacing,
                            Option.TabSpacing
                            );
      SaveIniFile := True;
    end;
    if SaveIniFile then IniFile.UpdateFile;

    {--------------------------------------------------------------------------}

    // Prepare FileList
    InitializeStringList( FileList );
    FileList.BackupOption := Option.BackupFile;

    // Prepare RootPathList
    if optRootPaths in Option.OptionUsed then
    begin
      RootPathList.DelimitedText := Option.RootPaths;
    end
    else
    begin
      RootPathList.DelimitedText := IniFile.ReadString( Option.IniSectionName,
                                                        IniKeyRootPathList,
                                                        Option.RootPaths
                                                        );
    end;

    // Prepare ExcludesList
    InitializeStringList( ExcludesList );
    ExcludesList.DelimitedText := IniFile.ReadString( Option.IniSectionName,
                                                      IniKeyExcludesList,
                                                      IniKeyExcludesListDefault
                                                      );

    // Prepare IncludesList
    InitializeStringList( IncludesList );
    IncludesList.DelimitedText := IniFile.ReadString( Option.IniSectionName,
                                                      IniKeyIncludesList,
                                                      IniKeyIncludesListDefault
                                                      );

    // Prepare ExtensonList
    InitializeStringList( ExtensonList );
    if optExtensions in Option.OptionUsed then
    begin
      ExtensonList.DelimitedText := Option.Extensions;
    end
    else
    begin
      ExtensonList.DelimitedText := IniFile.ReadString( Option.IniSectionName,
                                                        IniKeyExtensonList,
                                                        IniKeyExtensonListDefault
                                                        );
    end;

    // Prepare SkipDirsList
    InitializeStringList( SkipDirsList );
    SkipDirsList.DelimitedText := IniFile.ReadString( Option.IniSectionName,
                                                      IniKeySkipDirsList,
                                                      IniKeySkipDirsDefault
                                                      );
    SkipDirsList.Add( '.' );
    SkipDirsList.Add( '..' );

    {--------------------------------------------------------------------------}

    // Prepare TabReplace, TabReports and TabSpacing
    if not ( optTabReplace in Option.OptionUsed ) then
    begin
      Option.TabReplace := IniFile.ReadBool(  Option.IniSectionName,
                                              IniKeyTabReplace,
                                              Option.TabReplace
                                              );
    end;
    if not ( optTabReports in Option.OptionUsed ) then
    begin
      Option.TabReports := IniFile.ReadBool(  Option.IniSectionName,
                                              IniKeyTabReports,
                                              Option.TabReports
                                              );
    end;
    if not ( optTabSpacing in Option.OptionUsed ) then
    begin
      Option.TabSpacing := IniFile.ReadInteger( Option.IniSectionName,
                                                IniKeyTabSpacing,
                                                Option.TabSpacing
                                                );
    end;

    {--------------------------------------------------------------------------}

    Jadex := Length( Option.FilesPaths );
    if Jadex > 0 then
    begin
      Dec( Jadex );
      for Index := 0 to Jadex do
      begin
        FileName := Option.FilesPaths[ Index ];
        if DirectoryExists( FileName ) then
        begin
          FileList.AddFiles( FileName, Option.Recursive, SkipDirsList );
        end
        else
        begin
          FileList.Add( FileName );
        end;
      end;
    end
    else
    begin
      // Locate first valid RootPathList entry
      RootPath := ''; Index := 0;
      while ( Length( RootPath ) <= 0 ) and ( Index < RootPathList.Count ) do
      begin
        FileName := RootPathList.Strings[ Index ];
        if DirectoryExists( FileName ) then
        begin
          RootPath := FileName;
        end;

        Inc( Index );
      end;

      // Enumerate valid RootPathList entry
      if DirectoryExists( RootPath ) then
      begin
        RootPath := IncludeTrailingPathDelimiter( RootPath );

        // Enumerate IncludesList entries
        for Index := 0 to IncludesList.Count - 1 do
        begin
          // INI File selection is always recursive
          FileList.AddFiles( RootPath + IncludesList.Strings[ Index ], True, SkipDirsList );
        end;

        // Remove ExcludesList entries
        Index := 0; Jadex := 0;
        while ( Index < ExcludesList.Count ) and ( Jadex < FileList.Count ) do
        begin
          FileName := IncludeTrailingPathDelimiter( RootPath + ExcludesList.Strings[ Index ] );

          Compare := CompareText( FileName, Copy( FileList.Strings[ Jadex ], 1, Length( FileName ) ) );

          if Compare < 0 then
          begin
            // ExcludesList < FileList
            Inc( Index );
          end
          else
          if Compare > 0 then
          begin
            // ExcludesList > FileList
            Inc( Jadex );
          end
          else
          begin
            // ExcludesList = FileList
            FileList.Delete( Jadex );
          end;
        end;
      end;
    end;

    // Keep ExtensonList entries
    Index := 0;
    while Index < FileList.Count do
    begin
      FileExtn := Copy( ExtractFileExt( FileList.Strings[ Index ] ), 2, MaxInt );

      if ExtensonList.IndexOf( FileExtn ) >= 0 then
      begin
        // FileExtn present, retain
        FileList.Objects[ Index ] := TFileRecord.Create;
        Inc( Index );
      end
      else
      begin
        // FileExtn absent, discard
        FileList.Delete( Index );
      end;
    end;

    {--------------------------------------------------------------------------}

    // Remove extra white space
    EditedTrim := 0;
    for Index := 0 to FileList.Count - 1 do
    begin
      FileName := FileList.Strings[ Index ];

      if FileEdit.EditWhiteSpace( FileName ) then
      begin
        Write( 'Edit: ', FileName );
        if SaveChangeYes and FileList.Backup( Index ) then
        begin
          FileEdit.SaveToFile( FileName );
          Inc( EditedTrim );
        end;
        WriteLn;
      end;
    end;

    {--------------------------------------------------------------------------}

    // Replace tabs
    EditedTabs := 0;
    if Option.TabReplace then
    begin
      for Index := 0 to FileList.Count - 1 do
      begin
        FileName := FileList.Strings[ Index ];


        if FileEdit.EditTabs( FileName, Option.TabSpacing ) then
        begin
          Write( 'Tabs: ', FileName );
          if SaveChangeYes and FileList.Backup( Index ) then
          begin
            FileEdit.SaveToFile( FileName );
            Inc( EditedTabs );
          end;
          WriteLn;
        end;
      end;
    end;

    {--------------------------------------------------------------------------}

    // Report where tabs exist
    FinderTabs := 0;
    if Option.TabReports then
    begin
      for Index := 0 to FileList.Count - 1 do
      begin
        FileName := FileList.Strings[ Index ];
        TabLines := FileEdit.FindTabs( FileName );

        if Length( TabLines ) > 0 then
        begin
          WriteLn( 'Tabs: ', FileName, ', lines ', TabLines );
          Inc( FinderTabs );
        end;
      end;
    end;

    {--------------------------------------------------------------------------}

    WriteLn( Format( MessageFini, [ FileList.Count, EditedTrim, EditedTabs, FinderTabs ] ) );

    {--------------------------------------------------------------------------}

  finally
    FreeAndNil( IniFile );
    FreeAndNil( SkipDirsList );
    FreeAndNil( ExtensonList );
    FreeAndNil( IncludesList );
    FreeAndNil( ExcludesList );
    FreeAndNil( RootPathList );
    FreeAndNil( FileList );
    FreeAndNil( FileEdit );
  end;

  {----------------------------------------------------------------------------}

end;

{==============================================================================}

end.
