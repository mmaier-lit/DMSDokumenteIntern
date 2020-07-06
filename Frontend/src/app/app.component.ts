import { Component, ViewChild, OnInit } from '@angular/core';
import { BackendService } from './backend.service';
import {MatSort} from '@angular/material/sort';
import {MatTableDataSource} from '@angular/material/table';
import {MatSnackBar} from '@angular/material/snack-bar';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit{

  rueckmeldeNr = "";
  artikel = "";

  displayedColumns: string[] = ['id', 'name', 'version', 'download'];
  dataSource: MatTableDataSource<any>;

  @ViewChild(MatSort, {static: true}) sort: MatSort;
  
  constructor(
    public backend: BackendService,
    private _snackBar: MatSnackBar
    ) {
  }

  ngOnInit() {
    this.dataSource = new MatTableDataSource();
    this.dataSource.sort = this.sort;
  }

  suchen() {
    if (this.rueckmeldeNr || this.artikel) {
      this.backend.suchen(this.rueckmeldeNr, this.artikel).subscribe(data => {
        /* Add Data and Sort */
        this.dataSource.data = data.ttDMSZeichnungen.ttDMSZeichnungenRow;
      }, error => {
          this._snackBar.open(error.error, '[ Fehler ]', {
            duration: 3000,
            verticalPosition: 'top',
            horizontalPosition: 'center'
          });
      })
    }
  }

  download(zeichnung){
    window.open(`http://localhost:8080/download?volume=${zeichnung.Volume}&container=${zeichnung.Container}&file=${zeichnung.DMSName}&extension=${zeichnung.FileExtension}`);
  }

}