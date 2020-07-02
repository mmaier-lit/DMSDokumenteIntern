import { Component, ViewChild, OnInit } from '@angular/core';
import { BackendService } from './backend.service';
import {MatSort} from '@angular/material/sort';
import {MatTableDataSource} from '@angular/material/table';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit{

  rueckmeldeNr = "";
  artikel = "";

  displayedColumns: string[] = ['id', 'name', 'version', 'download'];
  dataSource;

  @ViewChild(MatSort, {static: true}) sort: MatSort;
  
  constructor(public backend: BackendService) {
  }

  ngOnInit() {
    this.dataSource.sort = this.sort;
  }

  suchen() {
    if (this.rueckmeldeNr || this.artikel) {
      this.backend.suchen(this.rueckmeldeNr, this.artikel).subscribe(data => {
        /* Add Data and Sort */
        this.dataSource = new MatTableDataSource(data.ttDMSZeichnungen.ttDMSZeichnungenRow);
      })
    }
  }

  download(zeichnung) {
    this.backend.download(zeichnung);
  }

}