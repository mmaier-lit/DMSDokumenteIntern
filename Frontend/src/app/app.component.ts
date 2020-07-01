import { Component, OnInit } from '@angular/core';
import { BackendService } from './backend.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent{
  test = 'lit-zeichnungen';
  rueckmeldeNr = "";
  artikel = "";
  zeichnungen;

  constructor(public backend: BackendService) {
  }

  suchen() {
    if(this.rueckmeldeNr || this.artikel) {
      this.backend.suchen(this.rueckmeldeNr, this.artikel).subscribe(data => {
        if(data.includes('error:')){
          console.log('error')
        } else {
          this.zeichnungen = data.ttDMSZeichnungen.ttDMSZeichnungenRow;
        }
      })
    }
  }

  download() {
    window.open('http://localhost:8080/download');
  }

}