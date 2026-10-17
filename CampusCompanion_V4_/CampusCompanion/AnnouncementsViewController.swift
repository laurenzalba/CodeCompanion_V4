import UIKit
import CoreData

final class AnnouncementsViewController: UITableViewController {
    private var announcements: [CampusAnnouncement] = []
    private var selectedAnnouncement: CampusAnnouncement?
    private var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Announcements"
        tableView.rowHeight = 76
        tableView.estimatedRowHeight = 76
        seedInitialAnnouncementsIfNeeded()
        loadAnnouncements()
    }

    private func seedInitialAnnouncementsIfNeeded() {
        let request: NSFetchRequest<CampusAnnouncement> = CampusAnnouncement.fetchRequest()
        do {
            guard try context.count(for: request) == 0 else { return }
            let seeds: [(String, String, String, String, String)] = [
                ("Enrollment Period Extended", "August 3, 2026", "Registrar", "Urgent", "Registrar"),
                ("Library Hours Extended for Finals", "July 28, 2026", "Library", "Normal", "University Library"),
                ("Career Fair 2026", "July 20, 2026", "Career Services", "Normal", "Career Services"),
                ("Student Council Elections", "July 15, 2026", "Student Affairs", "Normal", "Student Affairs"),
                ("Campus Wi-Fi Maintenance", "July 10, 2026", "IT Services", "Urgent", "IT Services"),
                ("Intramural Sports Sign-Up", "July 5, 2026", "Athletics", "Normal", "Athletics Office")
            ]
            for (title, date, category, priority, postedBy) in seeds {
                let item = CampusAnnouncement(context: context)
                item.title = title; item.date = date; item.category = category
                item.priority = priority; item.postedBy = postedBy
            }
            try context.save()
        } catch { print("Seed error: \(error)") }
    }

    private func loadAnnouncements() {
        let request: NSFetchRequest<CampusAnnouncement> = CampusAnnouncement.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do { announcements = try context.fetch(request) }
        catch { announcements = []; print("Fetch error: \(error)") }
        tableView.reloadData()
    }

    @IBAction private func addAnnouncementTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Announcement", message: "Enter a title and category.", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Title" }
        alert.addTextField { $0.placeholder = "Category" }
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let self = self, let fields = alert?.textFields, fields.count == 2 else { return }
            let title = (fields[0].text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let category = (fields[1].text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty, !category.isEmpty else { return }
            let item = CampusAnnouncement(context: self.context)
            item.title = title
            item.category = category
            item.date = DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none)
            item.priority = "Normal"
            item.postedBy = category
            do { try self.context.save(); self.loadAnnouncements() }
            catch { self.context.rollback(); print("Insert error: \(error)") }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { announcements.count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AnnouncementCell", for: indexPath) as? AnnouncementCell else { return UITableViewCell() }
        cell.configure(with: announcements[indexPath.row]); return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedAnnouncement = announcements[indexPath.row]
        performSegue(withIdentifier: "ShowAnnouncementDetailSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowAnnouncementDetailSegue", let destination = segue.destination as? DetailViewController,
              let announcement = selectedAnnouncement else { return }
        destination.announcement = announcement
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let item = announcements[indexPath.row]
        context.delete(item)
        do { try context.save(); announcements.remove(at: indexPath.row); tableView.deleteRows(at: [indexPath], with: .automatic) }
        catch { context.rollback(); loadAnnouncements(); print("Delete error: \(error)") }
    }
}
