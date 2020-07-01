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
    if(this.rueckmeldeNr.length > 0 && this.ze)
    if(this.rueckmeldeNr) {
      this.backend.suchen(this.rueckmeldeNr).subscribe(data => {
        this.zeichnungen = data;
      })
    }
  }

  download() {
    window.open('http://localhost:8080/download');
}

}
