import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class BackendService {

  constructor(private http: HttpClient) { }
  
  suchen(rueckmeldeNr: String, artikel: String): any {
    return this.http.post("/lit-backend/ermittleZeichnungen", {"rueckmeldeNummer": rueckmeldeNr,"artikel": artikel});
  }

  download(zeichnung) {
    return this.http.post("/lit-backend/download", {
      "volume": zeichnung.Volume,
      "container": zeichnung.Container,
      "name": zeichnung.Name,
      "extension": zeichnung.Extension
    });
  }
}
