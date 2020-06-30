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

/* Übergebene Parameter auspacken */ 
assign
  cUUID    = entry(1, session:parameter)
  cArtikel = entry(2, session:parameter)
  cRueckNr = entry(3, session:parameter)
  cAusgabe = entry(4, session:parameter)
  cAusgabe = cAusgabe + chr(92) + cUUID + '.xml'.


/* TempTable für den XML Export definieren */
define temp-table ttDMSZeichnungen no-undo
  field ID                        as integer
  field Name                      as character
  field IndexNr                   as integer

  index Main is unique primary
    ID.

/* Zeichnungen suchen und in TempTable schreiben */
create ttDMSZeichnungen.

assign
  ttDMSZeichnungen.ID      = 1
  ttDMSZeichnungen.Name    = 'testName':U
  ttDMSZeichnungen.IndexNr = 0.

validate ttDMSZeichnungen.

/* TempTable exportieren */
Temp-Table ttDMSZeichnungen:write-xml('file':U, 			    /* TargetType 		*/
                                      cAusgabe,                 /* File 			*/
                                      yes, 						/* Formatted 		*/
                                      ?,						/* Encoding 		*/
                                      ?,						/* SchemaLocation 	*/
                                      no, 						/* WriteSchema 		*/
                                      no).						/* MinSchema 		*/

quit.
