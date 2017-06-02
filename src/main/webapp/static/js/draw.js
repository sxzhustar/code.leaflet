function toDraw(i){
	console.log(map.editTools);
	switch(i){
	case 0:
//		map.editTools.
		break;
	case 2:
		map.editTools.startMarker();
		break;
	case 3:
		map.editTools.startPolyline().on('editable:drawing:end', this.editor);;
		break;
	case 4:
		map.editTools.startPolygon();
		break;
	}
}