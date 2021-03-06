package org.bigbluebutton.modules.present.ui.views.models
{
	import org.bigbluebutton.common.LogUtil;

	[Bindable]
	public class SlideViewModel
	{
		public static const MAX_ZOOM_PERCENT:Number = 400;
		public static const HUNDRED_PERCENT:Number = 100;
		
		public var viewportX:Number = 0;
		public var viewportY:Number = 0;
		public var viewportW:Number = 0;
		public var viewportH:Number = 0;
		
		private var _viewedRegionX:Number = 0;
		private var _viewedRegionY:Number = 0;
		private var _viewedRegionW:Number = HUNDRED_PERCENT;
		private var _viewedRegionH:Number = HUNDRED_PERCENT;
		
		private var _pageOrigW:Number = 0;
		private var _pageOrigH:Number = 0;
		private var _calcPageW:Number = 0;
		private var _calcPageH:Number = 0;
		private var _calcPageX:Number = 0;
		private var _calcPageY:Number = 0;
		private var _parentW:Number = 0;
		private var _parentH:Number = 0;
		
		public var loaderW:Number = 0;
		public var loaderH:Number = 0;
		public var loaderX:Number = 0;
		public var loaderY:Number = 0;
		

		
		public var fitToPage:Boolean = true;
		public var hasPageLoaded:Boolean = false;
		
		// After lots of trial and error on why synching doesn't work properly, I found I had to 
		// multiply the coordinates by 2. There's something I don't understand probably on the
		// canvas coordinate system. (ralam feb 22, 2012)
		private const MYSTERY_NUM:int = 2;
		
		public function set parentW(width:Number):void {
			_parentW = width;
		}
		
		public function set parentH(height:Number):void {
			_parentH = height;
		}
		
		public function get parentW():Number {
			return _parentW;
		}
		
		public function get parentH():Number {
			return _parentH;
		}
		
		public function get pageOrigW():Number {
			return _pageOrigW;
		}
		
		public function get pageOrigH():Number {
			return _pageOrigH;
		}
		
		public function get viewedRegionW():Number {
			return _viewedRegionW;
		}
		
		public function get viewedRegionH():Number {
			return _viewedRegionH;
		}
		
		public function get viewedRegionX():Number {
			return _viewedRegionX;
		}
		
		public function get viewedRegionY():Number {
			return _viewedRegionY;
		}
		
		public function reset(pageWidth:Number, pageHeight:Number):void {
			_calcPageW = _pageOrigW = pageWidth;
			_calcPageH = _pageOrigH = pageHeight;
			fitToPage = true;
			
			if (pageHeight > pageWidth) {
				fitToPage = false;
			}
//			LogUtil.debug("reset[" + fitToPage + "," + pageOrigW + "," + pageOrigH + "]");
		}

		public function resetForNewSlide(pageWidth:Number, pageHeight:Number):void {
			fitToPage = true;
			
			if (pageHeight > pageWidth) {
				fitToPage = false;
			}
			
//			LogUtil.debug("resetForNewSlide[" + fitToPage + "," + pageOrigW + "," + pageOrigH + "]");
			
			_calcPageW = _pageOrigW = pageWidth;
			_calcPageH = _pageOrigH = pageHeight;
			_calcPageX = 0;
			_calcPageY = 0;		
			_viewedRegionW = _viewedRegionH = HUNDRED_PERCENT;
			_viewedRegionX = _viewedRegionY = 0;
		}
		
		public function parentChange(parentW:Number, parentH:Number, fitToPage:Boolean):void {
			viewportW = this.parentW = parentW;
			viewportH = this.parentH = parentH;
//			this.fitToPage = fitToPage;
		}
		
		public function calculateViewportXY():void {
			viewportX = SlideCalcUtil.calculateViewportX(viewportW, parentW);
			viewportY = SlideCalcUtil.calculateViewportY(viewportH, parentH);			
	    }
	
		private function calcViewedRegion():void {
			_viewedRegionW = SlideCalcUtil.calcViewedRegionWidth(fitToPage, viewportW, _calcPageW);
			_viewedRegionH = SlideCalcUtil.calcViewedRegionHeight(fitToPage, viewportH, _calcPageH);
			_viewedRegionX = SlideCalcUtil.calcViewedRegionX(fitToPage, _calcPageX, _calcPageW);
			_viewedRegionY = SlideCalcUtil.calcViewedRegionY(fitToPage, _calcPageY, _calcPageH);
		}
		
		public function displayPresenterView():void {
			loaderX = Math.round(_calcPageX);
			loaderY = Math.round(_calcPageY);
			loaderW = Math.round(_calcPageW);
			loaderH = Math.round(_calcPageH);
		}
		
		public function adjustSlideAfterParentResized():void {
			if (fitToPage) {
				calculateViewportNeededForRegion(_viewedRegionX, _viewedRegionY, _viewedRegionW, _viewedRegionH);
				displayViewerRegion(_viewedRegionX, _viewedRegionY, _viewedRegionW, _viewedRegionH);
				calculateViewportXY();
				displayPresenterView();
				printViewedRegion();
			} else {
				calculateViewportSize();
				calculateViewportXY();
				_calcPageW = SlideCalcUtil.calcCalcPageSizeWidth(fitToPage, viewportW, _viewedRegionW);
				_calcPageH = SlideCalcUtil.calcCalcPageSizeHeight(fitToPage, viewportH, _viewedRegionH, _calcPageW, _calcPageH, _pageOrigW, _pageOrigH);
				calcViewedRegion();
				onResizeMove();				
			}			
		}
		
		private function doWidthBoundsDetection():void {
			if (_calcPageX >= 0) {
				// Don't let the left edge move inside the view.
				_calcPageX = 0;
			} else if ((_calcPageW + _calcPageX * MYSTERY_NUM) < viewportW) {
				// Don't let the right edge move inside the view.
				_calcPageX = (viewportW - _calcPageW) / MYSTERY_NUM;
			} else {
				// Let the move happen.
			}			
		}
		
		private function doHeightBoundsDetection():void {
			if (_calcPageY >= 0) {
				// Don't let the top edge move into the view.
				_calcPageY = 0;
			} else if ((_calcPageH + _calcPageY * MYSTERY_NUM) < viewportH) {
				// Don't let the bottome edge move into the view.
				_calcPageY = (viewportH - _calcPageH) / MYSTERY_NUM;
			} else {
				// Let the move happen.
			}			
		}
		
		private function onResizeMove():void {
			if (fitToPage) {			
				doWidthBoundsDetection();
				doHeightBoundsDetection();
			} else {			
				// The left edge should alway align the view.
				_calcPageX = 0;				
				doHeightBoundsDetection();	
			}
		}
		
		public function onMove(deltaX:Number, deltaY:Number):void {
			_calcPageX += deltaX;
			_calcPageY += deltaY;
			
			onResizeMove();	
			calcViewedRegion();
		}
		
		public function calculateViewportSize():void {
			viewportW = parentW;
			viewportH = parentH;
			
			if (fitToPage) {
				// If the height is smaller than the width, we use the height as the base to determine the size of the slide.
				if (parentH < parentW) {					
					viewportH = parentH;
					viewportW = ((pageOrigW * viewportH)/pageOrigH);					
					if (parentW < viewportW) {
						viewportW = parentW;
						viewportH = ((pageOrigH * viewportW)/pageOrigW);
					}
				} else {
					viewportW = parentW;
					viewportH = (viewportW/pageOrigW) * pageOrigH;
					if (parentH < viewportH) {
						viewportH = parentH;
						viewportW = ((pageOrigW * viewportH)/pageOrigH);
					}												
				}					
			} else {
				if (viewportW < pageOrigW) {
					viewportH = (viewportW/pageOrigW)*pageOrigH;
				}
			}		
		}	
			
		public function printViewedRegion():void {
			LogUtil.debug("Region [" + viewedRegionW + "," + viewedRegionH + "] [" + viewedRegionX + "," + viewedRegionY + "]");			
			LogUtil.debug("Region [" + ((viewedRegionW / HUNDRED_PERCENT)*_calcPageW) + "," + ((viewedRegionH/HUNDRED_PERCENT)*_calcPageH) + 
				"] [" + ((viewedRegionX/HUNDRED_PERCENT)*_calcPageW) + "," + ((viewedRegionY/HUNDRED_PERCENT)*_calcPageH) + "]");
		}
		
		public function onZoom(zoomValue:Number, mouseX:Number, mouseY:Number):void {
			if (fitToPage) {
				var cpw:Number = _calcPageW;
				var cph:Number = _calcPageH;
				var zpx:Number = Math.abs(_calcPageX) + mouseX;
				var zpy:Number = Math.abs(_calcPageY) + mouseY;
				var zpxp:Number = zpx/cpw;
				var zpyp:Number = zpy/cph;
				
				_calcPageW = pageOrigW * zoomValue / HUNDRED_PERCENT;
				_calcPageH = (_calcPageW/cpw) * cph; 
				
				var zpx1:Number = _calcPageW * zpxp;
				var zpy1:Number = _calcPageH * zpyp;				
				_calcPageX = -((zpx1 + zpx)/2) + mouseX;
				_calcPageY = -((zpy1 + zpy)/2) + mouseY;
				
				doWidthBoundsDetection();
				doHeightBoundsDetection();
				
				if ((zoomValue <= HUNDRED_PERCENT) || (_calcPageW < viewportW) || (_calcPageH < viewportH)) {
					_calcPageW = viewportW;
					_calcPageH = viewportH;
					_calcPageX = 0;
					_calcPageY = 0;
				} 
			} else {
				// For FTW, zooming isn't making the page bigger but actually scrolling.
				_calcPageX = 0;
				_calcPageY = (HUNDRED_PERCENT/MAX_ZOOM_PERCENT) * _calcPageH - (zoomValue/MAX_ZOOM_PERCENT) * _calcPageH;
				if (_calcPageY * MYSTERY_NUM + _calcPageH < viewportH) {
					_calcPageY = (viewportH - _calcPageH) / MYSTERY_NUM;
				}
			}
			
			calcViewedRegion();
		}
		
		public function displayViewerRegion(x:Number, y:Number, regionW:Number, regionH:Number):void {
			LogUtil.debug("** disp viewer 1 [" + regionW + "," + regionH + "][" + x + "," + y + "]");
			_calcPageW = viewportW/(regionW/HUNDRED_PERCENT);
			_calcPageH = viewportH/(regionH/HUNDRED_PERCENT);
			_calcPageX = (x/HUNDRED_PERCENT) * _calcPageW;
			_calcPageY =  (y/HUNDRED_PERCENT) * _calcPageH;					
			LogUtil.debug("** disp viewer 2 [" + viewportW + "," + viewportH + "][" +_calcPageW + "," + _calcPageH + "][" + _calcPageX + "," + _calcPageY + "]");
		}
		
		public function saveViewedRegion(x:Number, y:Number, regionW:Number, regionH:Number):void {
			_viewedRegionX = x;
			_viewedRegionY = y;
			_viewedRegionW = regionW;
			_viewedRegionH = regionH;
		}
		
		public function calculateViewportNeededForRegion(x:Number, y:Number, regionW:Number, regionH:Number):void {			
			var vrwp:Number = pageOrigW * (regionW/HUNDRED_PERCENT);
			var vrhp:Number = pageOrigH * (regionH/HUNDRED_PERCENT);
			
			if (parentW < parentH) {
				viewportW = parentW;
				viewportH = (vrhp/vrwp)*parentW;				 
				if (parentH < viewportH) {
					viewportH = parentH;
					viewportW = ((vrwp * viewportH)/viewportH);
					LogUtil.debug("calc viewport ***** resizing [" + viewportW + "," + viewportH + "] [" + parentW + "," + parentH + "," + fitToPage + "] [" + pageOrigW + "," + pageOrigH + "]");
				}
			} else {
				viewportH = parentH;
				viewportW = (vrwp/vrhp)*parentH;
				if (parentW < viewportW) {
					viewportW = parentW;
					viewportH = ((vrhp * viewportW)/vrwp);
					LogUtil.debug("calc viewport resizing [" + viewportW + "," + viewportH + "] [" + parentW + "," + parentH + "," + fitToPage + "] [" + pageOrigW + "," + pageOrigH + "]");
				}
			}
		}
	}
}