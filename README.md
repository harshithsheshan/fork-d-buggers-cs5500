<img src="./media/banner.png" alt="banner" />

# Final Project!

## The Final Project Repository!

Welcome to the final project repository!  

Here is a welcome video showing the repoisory organization--be sure to read carefully through the instructions (Consuming a large spec and breaking it down is part of engineering!).

<a href="https://youtu.be/F0XVOL1zQHM">
<img src="./media/FinalProject.png" alt="Click for final project video" width="300">
</a>

https://youtu.be/F0XVOL1zQHM


## Repository Organization 

1. There are no more individual assignments.
2. You will complete your final project in the [final project directory](./FinalProject). The organization is partially up to you on the file structure and organization, just make sure you organize it logically and against any requirements.

## Team

**Team Name**: *d-buggers*

Team member Names:

1. *Harshith Sheshan*
2. *Harsh Hasmukh Parmar*
3. *Sriyuth Sagi*

## Setup steps:

1. Clone this repository
2. Open a terminal, at the project root level, run command
	``` dub run -- server```
3. Open a new terminal, at the project root level, run command
	``` dub run -- client```
4. For adding new clients, follow step 3

## How to use:
Once the app is open, user can the different functionalities in the menu section to paint. Please refer the screenshot below:
<img width="764" alt="image" src="https://user-images.githubusercontent.com/16721521/233140823-f5be4dfb-a366-49f7-a8ac-3e6e5e7d3557.png">

1. The first option from the left is to save any drawing. The image gets saved in BMP format.
2. The second option from the left is to open any BMP format image and the user can continue drawing on it.
3. The next two options for the undo and redo features respectively. When multiple clients are working on the same canvas, a user can redo/undo only its own changes.
4. User can increase or descrease the brush size using the +/- options.
5. User can also change the colors by clicking on any of the available color option in the menu.
6. Also, users can chat with other clients using the terminal. We have network chat enabled so if the user send a message in the terminal, it gets broadcasted to the other clients along with the information on who sent it.
7. We have also implemented networking so that multiple clients can work on the same drawing canvas simultaneously. The system is equiped to work with any number of clients. Below is an example with 3 clients.
<img width="1440" alt="image" src="https://user-images.githubusercontent.com/16721521/233143690-b7f3ecb1-84c8-4800-ae15-be510fdd765c.png">



# Team spread sheet 

- Your team members and project manager are listed on the following spreadsheet [here](https://docs.google.com/spreadsheets/d/1Z81Es6K-AAlTdzFNmQA32MbcQVekF6jEHnhKCKACF2w/edit?usp=sharing). 
- Your project manager will be your first point of contact for various project deliverables and questions. Though you may continue to attend office hours with whoever you like, your project manager will be your primary contact.

## Team Logistics

- Work with your team to ensure everyone has a way to work on this codebase with a common set of tools.
- Everyone should make code contributions to the repository (i.e. everyone should have some commits in the commit history -- even if you pair program, that means you need to switch who is in control!)
- See the project timeline
- Note: In semesters where I have a 'token system' for late days, **you cannot use any tokens** for the final project.

## Notes on working in teams

* [Four Ways to Lead Your Software Team to Success](https://hackernoon.com/four-ways-to-lead-software-team-to-success-43fa156719b4)
* [The 3 C's of being a captain](https://appliedsportpsych.org/resources/resources-for-athletes/the-3-c-s-of-being-a-captain/)
* [Etiquette for Pair Programming](https://dzone.com/articles/etiquette-for-pair-programming)

# Rubric
 
<table>
	<tbody>
		<tr>
			<th>Points</th>
			<th align="center">Description</th>
			</tr>
			<tr>	  
			<td>10% (Milestone Check-in #1)</td>
				<td align="left">
					<ul><li>Did you complete your check-in #1?</li><li>Was a timeline present?</li><li>Were there at least 10 asks created in the 'Projects' tab</li></ul>
				</td>
		</tr>
	</tbody>
</table>

<table>
	<tbody>
		<tr>
			<th>Points</th>
			<th align="center">Description</th>
			</tr>
			<tr>	  
			<td>10% (Milestone Check-in #2)</td>
			<td align="left">
				<ul><li>Did you complete your check-in #2?</li>
			</td>
		</tr>
	</tbody>
</table>


<table>
	<tbody>
		<tr>
			<th>Points</th>
			<th align="center">Description</th>
			</tr>
			<tr>	  
			<td>5% (Youtube Video)</td>
			<td align="left">
				<ul><li>Did you upload a Youtube Video and test out opening it incognito mode so we could also access it?</li>
			</td>
		</tr>
	</tbody>
</table>

<table>
  <tbody>
    <tr>
      <th>Points</th>
      <th align="center">Description</th>
    </tr>
     <tr>
	<td>10% (Team Assessment)</td>
	<td align="left"><ul><li>Did you complete the assessment form which earns you 2%--the other 8% is determined by your team members responses</li><li>Note: In rare instances the instructor reserves the right to weigh the Team assessment more heavily. In the instance that a team member scores very low, the instructor will individually evaluate that students grade for the project.</li></ul></td>
    </tr>	     
  </tbody>
</table>  


<table>
  <tbody>
    <tr>
      <th>Points</th>
      <th align="center">Description</th>
    </tr>
     <tr>
	<td>25% (Polish and completion)</td>
	<td align="left"><ul><li>How polished are your materials(timeline, documentation, presentation)? Does your software work? Does it compile? Does it crash, segfault?</li></ul></td>
    </tr>	     
  </tbody>
</table>  

<table>
  <tbody>
    <tr>
      <th>Points</th>
      <th align="center">Description</th>
    </tr>	     
      <td>10% (Feature of your choice)</td>
	<td align="left"><ul><li>Does your feature work? Do you have at least 1 test case</li></ul></td> 
    </tr>
  </tbody>
</table>

<table>
  <tbody>
    <tr>
      <th>Points</th>
      <th align="center">Description</th>
    </tr>	     
      <td>20% (Networking)</td>
	<td align="left"><ul><li>Does your networking work?</li></ul></td> 
    </tr>
  </tbody>
</table>

<table>
  <tbody>
    <tr>
      <th>Points</th>
      <th align="center">Description</th>
    </tr>	     
      <td>10% (Testing)</td>
	<td align="left"><ul><li>Do you have at least 8 unit test cases? Are they properly integrated with a Github Action?</li></ul></td> 
    </tr>
  </tbody>
</table>

**Note** To be 100% clear, every team member gets the same grade with the exception of the peer assessment.
