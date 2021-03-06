{$IFNDEF JEDILMHLOG_INC}
{$DEFINE JEDILMHLOG_INC}

{******************************************************************************}
{                                                                              }
{ Lan Manager Audit API and Error Log API interface Unit for Object Pascal     }
{                                                                              }
{ Portions created by Microsoft are Copyright (C) 1995-2001 Microsoft          }
{ Corporation. All Rights Reserved.                                            }
{                                                                              }
{ The original file is: lmaudit.h, released November 2001.                     }
{ The original file is: lmerrlog.h, released November 2001.                    }
{                                                                              }
{ The original Pascal code is: LmAudit.pas, released Februari 2002.            }
{ The original Pascal code is: LmErrLog.pas, released Februari 2002.           }
{                                                                              }
{ The initial developer of the Pascal code is:                                 }
{     Marcel van Brakel (brakelm att chello dott nl).                          }
{                                                                              }
{ Portions created by Marcel van Brakel are Copyright (C) 1999-2001            }
{ Marcel van Brakel. All Rights Reserved.                                      }
{                                                                              }
{ Obtained through: Joint Endeavour of Delphi Innovators (Project JEDI)        }
{                                                                              }
{ You may retrieve the latest version of this file at the Project JEDI         }
{ APILIB home page, located at http://jedi-apilib.sourceforge.net              }
{                                                                              }
{ The contents of this file are used with permission, subject to the Mozilla   }
{ Public License Version 1.1 (the "License"); you may not use this file except }
{ in compliance with the License. You may obtain a copy of the License at      }
{ http://www.mozilla.org/MPL/MPL-1.1.html                                      }
{                                                                              }
{ Software distributed under the License is distributed on an "AS IS" basis,   }
{ WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for }
{ the specific language governing rights and limitations under the License.    }
{                                                                              }
{ Alternatively, the contents of this file may be used under the terms of the  }
{ GNU Lesser General Public License (the  "LGPL License"), in which case the   }
{ provisions of the LGPL License are applicable instead of those above.        }
{ If you wish to allow use of your version of this file only under the terms   }
{ of the LGPL License and not to allow others to use your version of this file }
{ under the MPL, indicate your decision by deleting  the provisions above and  }
{ replace  them with the notice and other provisions required by the LGPL      }
{ License.  If you do not delete the provisions above, a recipient may use     }
{ your version of this file under either the MPL or the LGPL License.          }
{                                                                              }
{ For more information about the LGPL: http://www.gnu.org/copyleft/lesser.html }
{                                                                              }
{******************************************************************************}

type
  _HLOG = record
    time: DWORD;
    last_flags: DWORD;
    offset: DWORD;
    rec_offset: DWORD;
  end;
  {$EXTERNALSYM _HLOG}
  HLOG = _HLOG;
  {$EXTERNALSYM HLOG}
  LPHLOG = ^HLOG;
  {$EXTERNALSYM LPHLOG}
  PHLOG = ^HLOG;
  {$EXTERNALSYM PHLOG}

const
  LOGFLAGS_FORWARD  = 0;
  {$EXTERNALSYM LOGFLAGS_FORWARD}
  LOGFLAGS_BACKWARD = $1;
  {$EXTERNALSYM LOGFLAGS_BACKWARD}
  LOGFLAGS_SEEK     = $2;
  {$EXTERNALSYM LOGFLAGS_SEEK}

{$ENDIF JEDIAPILIB_INC}
