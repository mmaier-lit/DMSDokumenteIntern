import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class BackendService {

  constructor(private http: HttpClient) { }
  
  suchen(rueckmeldeNr: Number) {
    return this.http.post("/lit-backend/ermittleZeichnungen", {"rueckmeldeNr": rueckmeldeNr});
  }
}
