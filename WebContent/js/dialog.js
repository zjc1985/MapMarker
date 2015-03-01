function NavBar(id){
	this.saveLinkClick=function(handler){
		$('#'+id).find('.saveLink').click(handler);
	};
	this.startSlideClick=function(handler){
		$('#'+id).find('.startSlideLink').click(handler);
	};
	this.prevSlideClick=function(handler){
		$('#'+id).find('.prevSlideLink').click(handler);
	};
	this.endSlideClick=function(handler){
		$('#'+id).find('.endSlideLink').click(handler);
	};
	this.createMarkerClick=function(handler){
		$('#'+id).find('.createMarkerBtn').click(handler);
	};
	this.createMarkerWithImageClick=function(handler){
		$('#'+id).find('.createMarkerWithImageBtn').click(handler);
	};
	this.createRoutineClick=function(handler){
		$('#'+id).find('.createRoutineBtn').click(handler);
	};
};

function MarkerInfo(id){
	this.show=function(){
		$('#'+id).modal('show');
	};
	
	this.hide=function(){
		$('#'+id).modal('hide');
	};
	
	this.setTitle=function(str){
		$('#'+id).find('.markerInfoTitle').text(str);
	};
	
	this.setSubTitle=function(str){
		$('#'+id).find('.markerInfoSubTitle').text(str);
	};
	
	this.setDescription=function(str){
		$('#'+id).find('.markerInfoDescription').text(str);
	};
	
	this.setImageSlider=function(urls){
		$('#'+id).find('.carousel-indicators').empty();
		$('#'+id).find('.carousel-inner').empty();
		
		for(var i in urls){
			var indicatorsHtml;
			var imageItemHtml;
			if(i==0){
				indicatorsHtml="<li data-target='#myCarousel' data-slide-to='0' class='active'></li>";
				imageItemHtml="<div class='item active'>"+
					"<img src="+urls[i]+"></div>";
			}else{
				indicatorsHtml="<li data-target='#myCarousel' data-slide-to='"+i+"'></li>";
				imageItemHtml="<div class='item'>"+
					"<img src="+urls[i]+"></div>";
			}
			$('#'+id).find('.carousel-indicators').append(indicatorsHtml);
			$('#'+id).find('.carousel-inner').append(imageItemHtml);
		}
	};
};

function OvMarkerInfo(id){
	extend(OvMarkerInfo,MarkerInfo,this,[id]);
	this.showRoutineDetail=function(handler){
		$("#"+id).find(".showDetailBtn").click(handler);
	};
	this.copyRoutineBtnClick=function(handler){
		$("#"+id).find(".copyRoutineBtn").click(handler);
	};
};

function MarkerEditor(id){
	
	this.confirmClick=function(handler){
		$("#"+id).find(".editConfirmBtn").click(handler);
	};
	
	this.deleteClick=function(handler){
		$("#"+id).find(".deleteBtn").click(handler);
	};
	
	this.setTitle=function(str){
		$('#'+id).find('.editTitle').val(str);	
	};
	this.getTitle=function(){
		return $('#'+id).find('.editTitle').val();
	};
	
	this.setCost=function(str){
		$('#'+id).find('.editCost').val(str);	
	};
	this.getCost=function(){
		return $('#'+id).find('.editCost').val();
	};
	
	this.setDesc=function(str){
		$('#'+id).find('.editDesc').val(str);	
	};
	this.getDesc=function(){
		return $('#'+id).find('.editDesc').val();
	};
	
	this.setUrls=function(urlArray){
		var str="";
		
		for(var i in urlArray){
			str=str+urlArray[i]+";\n";
		}
		$('#'+id).find('.editUrls').val(str);	
	};
	this.getUrls=function(){
		return $('#'+id).find('.editUrls').val().split(";");
	};
	
	this.setMaxSlideNum=function(maxNum){
		$('#'+id).find('.editSlideNum').empty();
		for(var i=1;i<maxNum+1;i++){
			$('#'+id).find('.editSlideNum').append("<option value='"+i+"'>"+i+"</option>");
		}	
	};
	
	this.getSlideNum=function(){
		return $('#'+id).find('.editSlideNum').val();
	};
	
	this.setSlideNum=function(slideNum){
		$('#'+id).find('.editSlideNum').val(slideNum);
	};
	
	this.setDropDownItems=function(items){
		$('#'+id).find('.dropdown-menu').empty();
		for(var i in items){
			var itemHtml="<li><a href='#'><img class='icon' src='"+items[i].url+"'>"+items[i].name+"</a></li>";
			$('#'+id).find('.dropdown-menu').append(itemHtml);
		}
		
		$('#'+id).find(".dropdown-menu li a").click(function(){
			  var selText = $(this).text();
			  var imgSrc=$(this).find('.icon').attr('src');
			  comboValue=selText;
			  $('#'+id).find('.selectedTxt').html(selText+' <span class="caret"></span>');
			  $('#'+id).find(".selectedImg").attr('src',imgSrc);
		});
	};
	
	this.setIconSelect=function(item){
		$('#'+id).find('.selectedTxt').html(item.name+' <span class="caret"></span>');
		$('#'+id).find(".selectedImg").attr('src',item.url);
	};
	
	this.getIconSelect=function(){
		return {url: $('#'+id).find(".selectedImg").attr('src'),
			name: $('#'+id).find('.selectedTxt').text().replace(/\s+/g,"")};
	};
};

function UploadImageModal(id) {
	this.fileNum=0;
	this.completeFileNum=0;
	
	this.progressSlice=0;
	this.currentProgress=0;
	
	var self=this;
	
	this.UIUploading=function(){
		$('#'+id).find('.loading').show();
	};
	
	this.UIFinishUpload=function(){
		$('#'+id).find('.loading').hide();
	};
	
	this.show = function() {
		$('#'+id).modal('show');
		self.UIFinishUpload();
	};
	
	this.close=function(){
		$('#'+id).modal('hide');
	};
	
	this.updateProgress=function(){
		self.currentProgress=self.currentProgress+self.progressSlice;
		$('#'+id).find('.progress').text(self.currentProgress+'%');
	};

	this.addChangeCallBack = function(callBack,allCompleteCallBack) {
		$('#'+id).find('.file').change(function() {
			var files = this.files;
			self.currentProgress=0;
			self.progressSlice=100 / files.length / 2;
			
			self.fileNum=files.length;
			self.completeFileNum=0;
			self.UIUploading();
			
			for(var i=0;i<files.length;i++){
				var file = files[i];
				$.fileExifLoadEnd(file,function(exifObject,imgFile){
					self.updateProgress();
					var lat = exifObject.GPSLatitude;
					var lon = exifObject.GPSLongitude;
					if (lat != null && lon != null) {
						//Convert coordinates to WGS84 decimal
						var latRef = exifObject.GPSLatitudeRef || "N";
						var lonRef = exifObject.GPSLongitudeRef || "W";
						lat = (lat[0] + lat[1] / 60 + lat[2] / 3600)
								* (latRef == "N" ? 1 : -1);
						lon = (lon[0] + lon[1] / 60 + lon[2] / 3600)
								* (lonRef == "W" ? -1 : 1);
					}
					
					//compress and change image file to base64 string
					var outputFormat="jpg";
					if(imgFile.type=="image/png"){
						outputFormat="png";
					}
					
					var reader=new FileReader();
					
					reader.addEventListener("load",function(event){
						var picDataUrl=event.target;
						
						var sourceImageObject=new Image();
						sourceImageObject.src=picDataUrl.result;
						
						var compressedPicDataUrl=jic.compress(sourceImageObject,30,outputFormat).src;
		                
						var base64PicString=compressedPicDataUrl.split(',')[1];
						
						callBack(base64PicString,lat,lon,imgFile.name);
					});
					
					reader.readAsDataURL(imgFile);
					
				});
				
			}	
		});
	};
	
}