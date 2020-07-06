import { Component, ViewChild, OnInit } from '@angular/core';
import { BackendService } from './backend.service';
import {MatSort} from '@angular/material/sort';
import {MatTableDataSource} from '@angular/material/table';
import {MatSnackBar} from '@angular/material/snack-bar';
import { Zeichnung } from './classes/zeichnung';
import {Sort} from '@angular/material/sort';


@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit{

  @ViewChild(MatSort, {static: true}) sort: MatSort;

  rueckmeldeNr: string = "";
  artikel: string = "";

  displayedColumns: string[] = ['id', 'name', 'index', 'version', 'download'];
  sortedData: Zeichnung[];
  dataSource: MatTableDataSource<Zeichnung>;
  
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
        this.dataSource.data = data.ttDMSZeichnungen.ttDMSZeichnungenRow as Zeichnung[];
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
    window.open(`http://30vs-pa-aps:8080/download?volume=${zeichnung.Volume}&container=${zeichnung.Container}&file=${zeichnung.DMSName}&extension=${zeichnung.FileExtension}`);
  }

  sortData(sort: Sort) {
    const data = this.dataSource.data.slice();
    if (!sort.active || sort.direction === '') {
      this.sortedData = data;
      return;
    }

    this.sortedData = data.sort((a, b) => {
      const isAsc = sort.direction === 'asc';
      switch (sort.active) {
        case 'id': return compare(a.ID, b.ID, isAsc);
        case 'name': return compare(a.Name, b.Name, isAsc);
        case 'index': return compare(a.IndexNumber, b.IndexNumber, isAsc);
        case 'version': return compare(a.VersionNumber, b.VersionNumber, isAsc);
        default: return 0;
      }
    });

    this.dataSource.data = this.sortedData;
  }

}

function compare(a: number | string, b: number | string, isAsc: boolean) {
  return (a < b ? -1 : 1) * (isAsc ? 1 : -1);
}