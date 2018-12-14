package tests;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

public class FileReadTest {

	private static void log(Object obj) {
		System.out.println(obj);
	}
	public FileReadTest() { 
		
	}
	
	/*
	 * 
	 * Play : 플레이 버튼 눌렀을 때
	 * Paused : 일시정지 버튼 눌렀을 때
	 * Seeking [시간] : Seek 바를 이동시켰을 때
	 * Completed : 마지막까지 플레이가 되었을 때
	 * Volume Changed [볼륨값] : 볼뷸이 바뀌었을 떄
	 * Muted [음소거여부] : Mute되었을 때
	 * PlaybackRateChanged [배속] : 플레이 속도가 바뀌었을 때
	 * Video Fullscreen [풀스크린여부] : 동영상이 풀스크린되거나 취소되었을 때
	 * Slide Fullscreen [풀스크린여부] : 슬라이드가 풀르크린되거나 취소되었을 때
	 * Previous Slide : 이전 슬라이드 이동 버튼을 눌렀을 때
	 * Next Slide : 다음 슬라이드 이동 버튼을 눌렀을 때
	 * Add Comment : 코멘트 추가할 때 
	 * Add Link : 링크 추가할 때
	 * Add Bookmark : 북마크 추가할 때
	 * Goto Slide [슬라이드 번호] : 슬라이드 장표 이동할 때
	 * SeekFR [시간] : 키보드 좌우키로 이동할 때
	 * Filtering Annotation [타입][보이기여부]: 특정 주석을 보이기/안보이기 했을 때
	 * Filtering (un)read [잠금여부] : 잠금 여부에 따라 보이기/안보이기 했을 때
	 * Filtering Behavior [타입][보이기여부] : 특정 Behavior 를 보이기/안보이기 했을 때 
	 * 
	 */
	

	public static class PlayerEventData {
		String userSeq;
		String courseSeq ;
		String slideSeq ;
		String time ;
		String eventData;
		Types type = Types.UNKNOWN; 
		String targetId ;
		public PlayerEventData() {
			
		}
		public PlayerEventData(String[] data) {
			this.courseSeq =data[0];	
			this.courseSeq =data[1];
			this.slideSeq = data[2];
			this.time = data[3];
			this.eventData = data[4];  
			this.targetId = "";
			for(Types t : Types.values() ) { 
				if( StringUtils.startsWith(eventData, t.text) ) {
					type = t;
					if( type == Types.CLICK_LINK || 
						type == Types.CLICK_ANNOTATION ||
						type == Types.CLICK_BOOKMARK || 
						type == Types.GOTO_SLIDE
					) {
						int start = eventData.indexOf("[") + 1;
						int end = eventData.indexOf("]") + 1;
						targetId = eventData.substring(start, end).trim();
					}
					break;
				}
			}
			
		} 

		
		
		@Override
		public String toString() {
			StringBuilder builder = new StringBuilder();
			builder.append("PlayerEventData [");
			if (userSeq != null)
				builder.append("userSeq=").append(userSeq).append(", ");
			if (courseSeq != null)
				builder.append("courseSeq=").append(courseSeq).append(", ");
			if (slideSeq != null)
				builder.append("slideSeq=").append(slideSeq).append(", ");
			if (time != null)
				builder.append("time=").append(time).append(", ");
			if (type != null)
				builder.append("type=").append(type).append(", ");
			if (targetId != null)
				builder.append("targetId=").append(targetId);
			builder.append("]");
			return builder.toString();
		} 

		public enum Types {
			UNKNOWN("Unknown"),
			PLAY("Play"),
			PAUSED("Paused"), //일시정지 버튼 눌렀을 때
			SEEKING("Seeking"), // [시간] : Seek 바를 이동시켰을 때
			COMPLETED("Completed"), // : 마지막까지 플레이가 되었을 때
			VOLUME_CHANGED("Volume Changed"), // [볼륨값] : 볼뷸이 바뀌었을 떄
			MUTED("Muted"), // [음소거여부] : Mute되었을 때
			PLAYBACKRATECHANGED("PlaybackRateChanged"), // [배속] : 플레이 속도가 바뀌었을 때
			VIDEO_FULLSCREEN("Video Fullscreen"), // [풀스크린여부] : 동영상이 풀스크린되거나 취소되었을 때
			SLIDE_FULLSCREEN("Slide Fullscreen"), // [풀스크린여부] : 슬라이드가 풀르크린되거나 취소되었을 때
			PREVIOUS_SLIDE("Previous Slide"), // : 이전 슬라이드 이동 버튼을 눌렀을 때
			NEXT_SLIDE("Next Slide"), // : 다음 슬라이드 이동 버튼을 눌렀을 때
			ADD_COMMENT("Add Comment"), // : 코멘트 추가할 때 
			ADD_LINK("Add Link"), // : 링크 추가할 때
			ADD_BOOKMARK("Add Bookmark"), // : 북마크 추가할 때
			GOTO_SLIDE("Goto Slide"), // [슬라이드 번호] : 슬라이드 장표 이동할 때
			SEEKFR("SeekFR"), // [시간] : 키보드 좌우키로 이동할 때
			FILTERING_ANNOTATION("Filtering Annotation"), // [타입][보이기여부]: 특정 주석을 보이기/안보이기 했을 때
			FILTERING_READ_OR_UNREAD("Filtering (un)read"), // [잠금여부] : 잠금 여부에 따라 보이기/안보이기 했을 때
			FILTERING_BEHAVIOR("Filtering Behavior"), // [타입][보이기여부] : 특정 Behavior 를 보이기/안보이기 했을 때
			CLICK_ANNOTATION("Click Annotation"),
			CLICK_BOOKMARK("Click Bookmark"),
			CLICK_LINK("Click Link"),
			;
			
			private String text; 
			
			private Types(String text ) {
				this.text = text; 
			}
			
			public String getText()
			{
				return this.text;
			} 
			
			public static Types getTypesByText(String text){
				Types selected = Types.UNKNOWN ;
				for( Types m : Types.values() )
				{
					if( StringUtils.equals(m.getText() , text ) ){
						selected = m;
						break;
					}
				}
				return selected;
			}
		}
		
	}
	
	public static class PlayerLogData {
		
		String level ;
		String catelogy;
		String date ;
		String userSeq ;
		String userName;
		String courseSeq ;
		String courseName ;
		String ip ;
		String url ;
		String etc ;
		String rowData ;
		List<PlayerEventData> events;
		
		public PlayerLogData(String[] data) {
			this.level = data[0];
			this.catelogy = data[1];
			this.date = data[2];
			this.userSeq = data[3];
			this.userName = data[4];
			this.courseSeq = data[5];
			this.courseName = data[6];
			this.ip = data[8];
			this.url = data[9];
			this.etc = data[10];
			this.rowData = data[11]; 
			this.events = new ArrayList<PlayerEventData>();
			parseRowData();
		}
		
		protected void parseRowData() { 
			rowData = StringUtils.removeStart(rowData, "[%AL]"); 
			String[] list = StringUtils.split(rowData, ",");
			int i = 0 ;
			for( String data : list) {
				i++;
				log( i+"> " +data);
				String[] list2 = StringUtils.split(rowData, ";");
				events.add(new PlayerEventData(list2));
			} 
		}
		
		@Override
		public String toString() {
			StringBuilder builder = new StringBuilder();
			builder.append("PlayerLogData [");
			if (level != null)
				builder.append("level=").append(level).append(", ");
			if (catelogy != null)
				builder.append("catelogy=").append(catelogy).append(", ");
			if (date != null)
				builder.append("date=").append(date).append(", ");
			if (userSeq != null)
				builder.append("userSeq=").append(userSeq).append(", ");
			if (userName != null)
				builder.append("userName=").append(userName).append(", ");
			if (courseSeq != null)
				builder.append("courseSeq=").append(courseSeq).append(", ");
			if (courseName != null)
				builder.append("courseName=").append(courseName).append(", ");
			if (ip != null)
				builder.append("ip=").append(ip).append(", ");
			if (url != null)
				builder.append("url=").append(url).append(", ");
			if (etc != null)
				builder.append("etc=").append(etc).append(", ");
			if (events != null)
				builder.append("\n event=").append(events);
			builder.append("]");
			return builder.toString();
		}
 
	}
	public static void main(String[] args) {
		try {
			String path = "/Users/donghyuck/Documents/andang72_workspace/ewha-dashboard/WebContent/WEB-INF/data/LplayLog.www.log.2018-12-08-15.log";
			try (BufferedReader br = new BufferedReader(new FileReader(path))) {
			    String line;
			    while ((line = br.readLine()) != null) {
			       // process the line.
			    	log (line) ;
			    	String[] list = StringUtils.split(line, "|");
			    	PlayerLogData data = new PlayerLogData(list);
			    	log(data);
			    }
			}
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

}
