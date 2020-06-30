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
define variable cLogging as character no-undo.
define variable iCounter as integer   no-undo.
define variable pa-firma as character no-undo.

/* Übergebene Parameter auspacken */ 
assign
  pa-firma = '000':U
  cUUID    = entry(1, session:parameter)
  cRueckNr = entry(2, session:parameter)
  cArtikel = entry(3, session:parameter)
  cAusgabe = entry(4, session:parameter)
  cLogging = cAusgabe + chr(92) + cUUID + '.error'
  cAusgabe = cAusgabe + chr(92) + cUUID + '.xml'.

/* Initialize Logging */  
output to cLogging.

/* TempTable für den XML Export definieren */
define temp-table ttDMSZeichnungen no-undo
  field ID                        as integer
  field Name                      as character
  field IndexNr                   as integer

  index Main is unique primary
    ID.

/* Zeichnungen suchen und in TempTable schreiben */

    define buffer bOS_Schlagworte        for OS_Schlagworte.
    define buffer bOD_Archive            for OD_Archive.
    define buffer bPP_Auftrag            for PP_Auftrag.
    define buffer bS_Artikel             for S_Artikel.
    define buffer bP_ZeichnungArtikel    for P_ZeichnungArtikel.
    define buffer bP_Zeichnung           for P_Zeichnung.
    
    if cRueckNr > '':U then do:
      find bPP_Auftrag
        where bPP_Auftrag.Firma        = pa-firma
          and bPP_Auftrag.RueckmeldeNr = integer(cRueckNr)
      no-lock no-error.

      if not available bPP_Auftrag then
        put unformatted 'Es wurde kein passender Produktionsauftrag gefunden!':U.
        return.
    end. /* cRueckNr > '':U */

    for each bOS_Schlagworte
      where bOS_Schlagworte.DokTypID = 40
      and bOS_Schlagworte.SchlagwortID = 1006
      and bOS_Schlagworte.SchlagwortWert = cArtikel
      no-lock:

      for each bOD_Archive
        where bOD_Archive.DokID = bOS_Schlagworte.DokID
        no-lock
        use-index Version
        break b bOD_Archive.ArchivIDRef:
        
        create ttDMSZeichnungen.

        assign 
          iCounter = iCounter + 1
          ttDMSZeichnungen.ID      = iCounter
          ttDMSZeichnungen.Name    = bOD_Archive.Dateiname
          ttDMSZeichnungen.IndexNr = bOD_Archive.Archivversion.

        validate ttDMSZeichnungen.
      end. /* for each bOD_Archive */
    end. /* for each bOS_Schlagworte */

/* TempTable exportieren */
Temp-Table ttDMSZeichnungen:write-xml('file':U, 			    /* TargetType 		*/
                                      cAusgabe,                 /* File 			*/
                                      yes, 						/* Formatted 		*/
                                      ?,						/* Encoding 		*/
                                      ?,						/* SchemaLocation 	*/
                                      no, 						/* WriteSchema 		*/
                                      no).						/* MinSchema 		*/

quit.
