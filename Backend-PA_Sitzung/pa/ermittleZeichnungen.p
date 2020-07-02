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
define variable pa-firma as character no-undo.

/* Übergebene Parameter auspacken */ 
assign
  pa-firma = '000':U
  cUUID    = entry(1, session:parameter)
  cRueckNr = entry(2, session:parameter)
  cArtikel = entry(3, session:parameter)
  cAusgabe = entry(4, session:parameter)
  cAusgabe = cAusgabe + chr(92) + cUUID + '.xml'.

/* TempTable für den XML Export definieren */
define temp-table ttDMSZeichnungen no-undo
  field ID                        as integer
  field Name                      as character
  field VersionNumber             as integer
  field Volume                    as character
  field Container                 as character
  field FileExtension             as character

  index Main is unique primary
    ID.

/* Zeichnungen suchen und in TempTable schreiben */
    define buffer bOS_Schlagworte        for OS_Schlagworte.
    define buffer bOD_Dokumente          for OD_Dokumente.
    define buffer bOD_Archive            for OD_Archive.
    define buffer bPP_Auftrag            for PP_Auftrag.
    define buffer bS_Artikel             for S_Artikel.
    define buffer bP_ZeichnungArtikel    for P_ZeichnungArtikel.
    define buffer bP_Zeichnung           for P_Zeichnung.
    define buffer bOD_Container          for OD_Container.
    define buffer bOD_Volumen            for OD_Volumen.
    
    /* ----------------------------------------------------------------------------- */
    /* - RückmeldeNummer ----------------------------------------------------------- */
    /* ----------------------------------------------------------------------------- */
    if cRueckNr > '':U then do:
      find bPP_Auftrag
        where bPP_Auftrag.Firma        = pa-firma
          and bPP_Auftrag.RueckmeldeNr = integer(cRueckNr)
      no-lock no-error.

      if not available bPP_Auftrag then do:
        undo, THROW NEW Progress.Lang.AppError("Der Produktionsauftrag " + cRueckNr + " wurde nicht gefunden!", 550).
      end.

      find bS_Artikel
        where bS_Artikel.Firma  = pa-firma
          and bS_Artikel.Artikel = bPP_Auftrag.Artikel
      no-lock no-error.

      if not available bS_Artikel then do:
        undo, THROW NEW Progress.Lang.AppError("Der Artikel des Produktionsauftrags " + cRueckNr + " wurde nicht gefunden!", 550).
      end.
    
      Loop1: for each bOS_Schlagworte
        where bOS_Schlagworte.DokTypID = 40
        and bOS_Schlagworte.SchlagwortID = 1006
        and bOS_Schlagworte.SchlagwortWert = bS_Artikel.Artikel
        no-lock:

        for each bOD_Archive
          where bOD_Archive.DokID = bOS_Schlagworte.DokID
          no-lock:

          find bOD_Container
            where bOD_Container.ContainerID = bOD_Archive.ContainerID
          no-lock.

          if not available bOD_Container then do:
            undo, THROW NEW Progress.Lang.AppError("Der Container " + string(bOD_Archive.ContainerID) + " wurde nicht gefunden!", 550).
          end.

          find bOD_Volumen
            where bOD_Volumen.VolumenID = bOD_Container.VolumenID
          no-lock.

          if not available bOD_Container then do:
            undo, THROW NEW Progress.Lang.AppError("Das Volumen " + string(bOD_Container.VolumenID) + " wurde nicht gefunden!", 550).
          end.  

          find bOD_Dokumente
            where bOD_Dokumente.DokID = bOS_Schlagworte.DokID
          no-lock.

          if not available bOD_Dokumente then do:
            undo, THROW NEW Progress.Lang.AppError("Das Dokument zur DokID " + string(bOS_Schlagworte.DokID) + " wurde nicht gefunden!", 550).
          end.        
          

          /* Abbruchbedingung, damit nicht zu viele geladen werden */
          if iCounter > 99 then
            leave Loop1.

          create ttDMSZeichnungen.

          assign 
            iCounter                       = iCounter + 1
            ttDMSZeichnungen.ID            = iCounter
            ttDMSZeichnungen.Name          = bOD_Archive.Dateiname
            ttDMSZeichnungen.FileExtension = bOD_Archive.DateiExtension
            ttDMSZeichnungen.VersionNumber = bOD_Dokumente.DokumentVersion
            ttDMSZeichnungen.Volume        = bOD_Volumen.Name
            ttDMSZeichnungen.Container     = bOD_Container.Name.
            .

          validate ttDMSZeichnungen.
        end. /* for each bOD_Archive */
      end. /* for each bOS_Schlagworte */
    end. /* cRueckNr > '':U */



    /* ----------------------------------------------------------------------------- */
    /* - Artikel ------------------------------------------------------------------- */
    /* ----------------------------------------------------------------------------- */
    if cArtikel > '':U and cRueckNr = '' then do:
      Loop2: for each bS_Artikel
        where bS_Artikel.Firma  = pa-firma
          and bS_Artikel.Artikel begins cArtikel
      no-lock:

    for each bOS_Schlagworte
      where bOS_Schlagworte.DokTypID = 40
      and bOS_Schlagworte.SchlagwortID = 1006
      and bOS_Schlagworte.SchlagwortWert = bS_Artikel.Artikel
      no-lock:

      for each bOD_Archive
        where bOD_Archive.DokID = bOS_Schlagworte.DokID
        no-lock:

        find bOD_Container
          where bOD_Container.ContainerID = bOD_Archive.ContainerID
        no-lock.

        if not available bOD_Container then do:
          undo, THROW NEW Progress.Lang.AppError("Der Container " + string(bOD_Archive.ContainerID) + " wurde nicht gefunden!", 550).
        end.

        find bOD_Volumen
          where bOD_Volumen.VolumenID = bOD_Container.VolumenID
        no-lock.

        if not available bOD_Container then do:
          undo, THROW NEW Progress.Lang.AppError("Das Volumen " + string(bOD_Container.VolumenID) + " wurde nicht gefunden!", 550).
        end.  

        find bOD_Dokumente
          where bOD_Dokumente.DokID = bOS_Schlagworte.DokID
        no-lock.

        if not available bOD_Dokumente then do:
          undo, THROW NEW Progress.Lang.AppError("Das Dokument zur DokID " + string(bOS_Schlagworte.DokID) + " wurde nicht gefunden!", 550).
        end.        
        

        /* Abbruchbedingung, damit nicht zu viele geladen werden */
        if iCounter > 99 then
          leave Loop2.

        create ttDMSZeichnungen.

        assign 
          iCounter = iCounter + 1
          ttDMSZeichnungen.ID            = iCounter
          ttDMSZeichnungen.Name          = bOD_Archive.Dateiname
          ttDMSZeichnungen.FileExtension = bOD_Archive.DateiExtension
          ttDMSZeichnungen.VersionNumber = bOD_Dokumente.DokumentVersion
          ttDMSZeichnungen.Volume        = bOD_Volumen.Name
          ttDMSZeichnungen.Container     = bOD_Container.Name.
          .

        validate ttDMSZeichnungen.
      end. /* for each bOD_Archive */
    end. /* for each bOS_Schlagworte */
    end. /* cArtikel > '':U */
  end. /* Loop2 (label) */

/* TempTable exportieren */
Temp-Table ttDMSZeichnungen:write-xml('file':U, 			/* TargetType 	  */
                                      cAusgabe,       /* File 			    */
                                      yes, 						/* Formatted 		  */
                                      ?,						  /* Encoding 		  */
                                      ?,						  /* SchemaLocation */
                                      no, 						/* WriteSchema 		*/
                                      no).						/* MinSchema 		  */

quit.
