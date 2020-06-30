/*****************************************************************************/
/*                                            (c) 2020  LIT Beratung GmbH    */
/*                                                      Flurstraße 4b        */
/*                                                      91086 Aurachtal      */
/*                                                                           */
/*  Projekt....: proALPHA                                                    */
/*                                                                           */
/*  erstellt am: 30.06.2020                                                  */
/*  Autor......: Marcel Maier                                                */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/*  Beschreibung                                                             */
/*---------------------------------------------------------------------------*/
/*                                                                           */
/* Das folgende Programm wird aus einem NPM Backend über ein OS-Command aus- */
/* geführt. Das Programm exportiert alle verfügbaren Zeichnungen als XML und */
/* speichert diese für das Backend mit der uuid ab, damit im Frontend eine   */
/* der Zeichnungen ausgewählt und angeschaut werden kann                     */
/*                                                                           */ 
/* Es werden folgende 3 Parameter mitgegeben:                                */
/*                                                                           */
/*             (1) uuid: Eine Anfrage ID des Rest Endpoints, über den        */
/*                       Daten abgelegt und wieder gefunden werden.          */
/*          (2) artikel: Dieser Parameter gibt die Artikelnummer an, für     */
/*                       welche die Zeichnungen ermittelt werden sollen.     */
/* (3) rueckmeldeNummer: Dieser Parameter gibt die RückmeldeNummer an, für   */
/*                       welche die Zeichnungen ermittelt werden sollen.     */
/*      (4) ausgabePfad: Gibt den Pfad zum Export-Verzeichnis an.            */
/*                                                                           */
/*---------------------------------------------------------------------------*/

define variable cUUID    as character no-undo.
define variable cArtikel as character no-undo. 
define variable cRueckNr as character no-undo.
define variable cAusgabe as character no-undo.
define variable iCounter as integer   no-undo.

/* Logging */
output to cAusgabe + 'client.log'.

/* Übergebene Parameter auspacken */ 
assign
  cUUID    = entry(1, session:parameter)
  cRueckNr = entry(2, session:parameter)
  cArtikel = entry(3, session:parameter)
  cAusgabe = entry(4, session:parameter)
  cAusgabe = cAusgabe + chr(92) + cUUID + '.xml'.

put unformatted cUUID + '|' + cRueckNr + '|' + cArtikel skip.

/* TempTable für den XML Export definieren */
define temp-table ttDMSZeichnungen no-undo
  field ID                        as integer
  field Name                      as character
  field IndexNr                   as integer

  index Main is unique primary
    ID.

/* Zeichnungen suchen und in TempTable schreiben */

    define buffer byOS_Schlagworte        for OS_Schlagworte.
    define buffer byOS_SchlagworteIndexNo for OS_Schlagworte.
    define buffer byOD_Archive            for OD_Archive.

    define variable iySchlagwortDokID  as integer   no-undo.
    define variable iyExportedDrawings as integer   no-undo.
    define variable cyExportedDrawing  as character no-undo.
    define variable cyExportTypes      as character no-undo.

    iySchlagwortDokID = 40.

    for each byOS_Schlagworte
      where byOS_Schlagworte.DokTypID = iySchlagwortDokID
      and byOS_Schlagworte.SchlagwortID = 1006
      and byOS_Schlagworte.SchlagwortWert = cArtikel
      no-lock:

      for each byOD_Archive
        where byOD_Archive.DokID = byOS_Schlagworte.DokID
        no-lock
        use-index Version
        break by byOD_Archive.ArchivIDRef:
        
        create ttDMSZeichnungen.

        assign 
          iCounter = iCounter + 1
          ttDMSZeichnungen.ID      = iCounter
          ttDMSZeichnungen.Name    = byOD_Archive.Dateiname
          ttDMSZeichnungen.IndexNr = byOD_Archive.Archivversion.

        validate ttDMSZeichnungen.
      end. /* for each byOD_Archive */
    end. /* for each byOS_Schlagworte */

/* TempTable exportieren */
Temp-Table ttDMSZeichnungen:write-xml('file':U, 			    /* TargetType 		*/
                                      cAusgabe,                 /* File 			*/
                                      yes, 						/* Formatted 		*/
                                      ?,						/* Encoding 		*/
                                      ?,						/* SchemaLocation 	*/
                                      no, 						/* WriteSchema 		*/
                                      no).						/* MinSchema 		*/

quit.
