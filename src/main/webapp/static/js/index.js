function pan(flag) {
	var size = map.getSize();// xy
	switch (flag) {
	case 'left':
		map.panBy(L.point(-size.x / 3, 0), {
			animate : true
		});
		break;
	case 'right':
		map.panBy(L.point(size.x / 3, 0), {
			animate : true
		});
		break;
	case 'up':
		map.panBy(L.point(0, -size.y / 3), {
			animate : true
		});
		break;
	case 'down':
		map.panBy(L.point(0, size.y / 3), {
			animate : true
		});
		break;
	}
}

function zoom(flag) {
	switch (flag) {
	case 'in':
		map.zoomIn(1, {
			animate : false
		});
		break;
	case 'out':
		map.zoomOut(1, {
			animate : false
		});
		break;
	case 'default':
		map.setView(mapCfg.center, 11, {
			animate : false
		});
		break;
	}
}

function toFullScreen() {
	var element = $('#map')[0];
	if (element.requestFullscreen) {
		element.requestFullscreen();
	} else if (element.mozRequestFullScreen) {
		element.mozRequestFullScreen();
	} else if (element.webkitRequestFullscreen) {
		element.webkitRequestFullscreen();
	} else if (element.msRequestFullscreen) {
		element.msRequestFullscreen();
	}
}

function exitFullscreen() {
	if (document.exitFullscreen) {
		document.exitFullscreen();
	} else if (document.mozCancelFullScreen) {
		document.mozCancelFullScreen();
	} else if (document.webkitExitFullscreen) {
		document.webkitExitFullscreen();
	}
}